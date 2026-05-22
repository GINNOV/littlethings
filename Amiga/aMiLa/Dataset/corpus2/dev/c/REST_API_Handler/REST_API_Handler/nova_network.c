// PolyNova3D (version 3.3)
/***************************************************************
 Copyright (C) 1999 Novasoft Consulting

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Library General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU Library General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *****************************************************************/

extern void logWarningMessage(const char *fmtString, ...);

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/amissl.h>
#include <proto/amisslmaster.h>

#include <amissl/amissl.h>
#include <libraries/amisslmaster.h>
#include <libraries/amissl.h>

#include <SDI_compiler.h>

/* Configuration */
#define API_HOST "leaderboarded.com"
#define API_PORT "443"

struct Library* AmiSSLMasterBase = NULL;
struct Library* SocketBase = NULL;
struct Library* AmiSSLBase = NULL;
struct Library* AmiSSLExtBase = NULL;

SSL_CTX *ctx = NULL;

#define GETINTERFACE(iface, base) TRUE
#define DROPINTERFACE(iface)
#define XMKSTR(x) #x
#define MKSTR(x)  XMKSTR(x)

#define HTTPS_DEBUG 0

/* Required callback to enable HTTPS connection, when necessary
 */
SAVEDS STDARGS BIO* HTTP_TLS_cb(BIO* bio, void* arg, int connect, int detail) {
	if (connect && detail) {
		BIO* sbio = BIO_new_ssl((SSL_CTX* )arg, 1);
		if (sbio != NULL) {
			SSL* ssl = NULL;

			BIO_get_ssl(sbio, &ssl);
			if (ssl != NULL) {
				/* REQUIRED for Cloudflare */
				SSL_set_tlsext_host_name(ssl, API_HOST);

				/* Optional but recommended */
				SSL_set_hostflags(ssl, X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS);
				SSL_set1_host(ssl, API_HOST);
			}

			bio = BIO_push(sbio, bio);
		} else {
			bio = NULL;
		}
	}

	return bio;
}

/* Stub function used when freeing our stack of headers
 */
SAVEDS STDARGS void stub_X509V3_conf_free(CONF_VALUE* val) {
	X509V3_conf_free(val);
}

int NetworkConnect() {
	if (!ctx) {
		int error = 0;

		if (!(SocketBase = OpenLibrary("bsdsocket.library", 4))) {
			error = 1;
			logWarningMessage("Couldn't open bsdsocket.library v4!\n");
		}

		if (!error) {
			if (!GETINTERFACE(ISocket, SocketBase)) {
				error = 1;
				logWarningMessage("Couldn't get Socket interface!\n");
			}
		}

		if (!error) {
			if (!(AmiSSLMasterBase = OpenLibrary("amisslmaster.library", AMISSLMASTER_MIN_VERSION))) {
				error = 1;
				logWarningMessage("Couldn't open amisslmaster.library v"MKSTR(AMISSLMASTER_MIN_VERSION) "!\n");
			}
		}

		if (!error) {
			if (!GETINTERFACE(IAmiSSLMaster, AmiSSLMasterBase)) {
				error = 1;
				logWarningMessage("Couldn't get AmiSSLMaster interface!\n");
			}
		}

		if (!error) {
			if (OpenAmiSSLTags(AMISSL_CURRENT_VERSION,
					AmiSSL_UsesOpenSSLStructs, FALSE,
					AmiSSL_GetAmiSSLBase, &AmiSSLBase,
					AmiSSL_GetAmiSSLExtBase, &AmiSSLExtBase,
					AmiSSL_SocketBase, SocketBase,
					AmiSSL_ErrNoPtr, &errno,
					TAG_DONE) != 0) {
				error = 1;
				logWarningMessage("Couldn't open and initialize AmiSSL!\n");
			}
		}

		if (!error) {
			ctx = SSL_CTX_new(TLS_client_method());
			if (!ctx) {
				logWarningMessage("Couldn't create SSL context!\n");
			} else {
				/* Force TLS 1.2 */
				SSL_CTX_set_min_proto_version(ctx, TLS1_2_VERSION);

				/* Reasonable modern cipher set */
				SSL_CTX_set_cipher_list(ctx, "HIGH:!aNULL:!MD5:!3DES");
			}
		}
	}

	if (ctx) {
		return 0;
	} else {
		return -1;
	}
}

void NetworkDisconnect() {
	if (ctx) {
		if (AmiSSLBase) {
			SSL_CTX_free(ctx);
			CloseAmiSSL();
			ctx = NULL;
		}

		if (AmiSSLMasterBase) {
			DROPINTERFACE(IAmiSSLMaster);
			CloseLibrary(AmiSSLMasterBase);
			AmiSSLMasterBase = NULL;
		}

		if (SocketBase) {
			DROPINTERFACE(ISocket);
			CloseLibrary(SocketBase);
			SocketBase = NULL;
		}
	}
}

/*
 * NOTE:
 * We deliberately use HTTP/1.0 to avoid chunked transfer encoding.
 * This keeps the client simple and compatible with AmiSSL.
 */
char* PerformHTTPSRequest(const char* method, const char* path, const char* body) {
	BIO *bio = NULL;
	BIO *ssl_bio = NULL;
	SSL *ssl = NULL;
	char request[2048];
	char *response = NULL;
	size_t response_len = 0;
	char buf[512];
	int len;

	/* ---------------- Create SSL BIO ---------------- */
	ssl_bio = BIO_new_ssl(ctx, 1);
	if (!ssl_bio)
		goto fail;

	BIO_get_ssl(ssl_bio, &ssl);
	if (!ssl)
		goto fail;

	/* REQUIRED for Cloudflare */
	SSL_set_tlsext_host_name(ssl, API_HOST);
	SSL_set1_host(ssl, API_HOST);

	/* ---------------- Create TCP connection ---------------- */
	bio = BIO_new_connect(API_HOST ":" API_PORT);
	if (!bio)
		goto fail;

	bio = BIO_push(ssl_bio, bio);

	if (BIO_do_connect(bio) <= 0)
		goto fail;

	if (BIO_do_handshake(bio) <= 0)
		goto fail;

	/* ---------------- Build HTTP request ---------------- */
	if (body)
	{
		snprintf(request, sizeof(request),
			"%s %s HTTP/1.0\r\n"
			"Host: %s\r\n"
			"User-Agent: AmigaGame/1.0\r\n"
			"Accept: application/json\r\n"
			"Content-Type: application/json\r\n"
			"Content-Length: %lu\r\n"
			"Connection: close\r\n"
			"\r\n"
			"%s",
			method,
			path,
			API_HOST,
			(unsigned long)strlen(body),
			body);
	}
	else
	{
		snprintf(request, sizeof(request),
			"%s %s HTTP/1.0\r\n"
			"Host: %s\r\n"
			"User-Agent: AmigaGame/1.0\r\n"
			"Accept: application/json\r\n"
			"Connection: close\r\n"
			"\r\n",
			method,
			path,
			API_HOST);
	}

#if HTTPS_DEBUG
	Printf("HTTPS SEND (%ld bytes):\n%s\n",
		   (LONG)strlen(request), request);
#endif

	/* ---------------- Send request ---------------- */
	if (BIO_write(bio, request, strlen(request)) <= 0)
		goto fail;

	BIO_flush(bio);

	/* 🔥 CRITICAL: signal end of request body */
	BIO_shutdown_wr(bio);

	/* ---------------- Read response ---------------- */
	while ((len = BIO_read(bio, buf, sizeof(buf))) > 0)
	{
#if HTTPS_DEBUG
		Printf("HTTPS RECV chunk: %ld bytes\n", (LONG)len);
#endif
		char *newbuf = realloc(response, response_len + len + 1);
		if (!newbuf)
			goto fail;

		response = newbuf;
		memcpy(response + response_len, buf, len);
		response_len += len;
		response[response_len] = 0;
	}

#if HTTPS_DEBUG
	Printf("HTTPS TOTAL RECEIVED: %ld bytes\n", (LONG)response_len);
#endif

	BIO_free_all(bio);
	bio = NULL;

	if (!response || response_len == 0)
		goto fail;

	/* ---------------- Strip HTTP headers ---------------- */
	char *body_start = strstr(response, "\r\n\r\n");
	if (!body_start)
		goto fail;

	body_start += 4;

	/* Skip whitespace */
	while (*body_start == '\r' || *body_start == '\n' || *body_start == ' ')
		body_start++;

	if (*body_start != '{' && *body_start != '[')
		goto fail;

	char *result = strdup(body_start);
	free(response);
	return result;

fail:
#if HTTPS_DEBUG
	Printf("HTTPS request failed\n");
#endif
	if (bio)
		BIO_free_all(bio);
	if (response)
		free(response);
	return NULL;
}


