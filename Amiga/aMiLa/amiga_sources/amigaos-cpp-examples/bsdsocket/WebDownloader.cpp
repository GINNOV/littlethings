//
// AmigaOS CPP Examples
//
// (c) 2023 TDolphin
//

//
// example of use of bsdsocket.library
//

#include "Core/BSDSocketBaseScope.hpp"
#include "Core/SocketScope.hpp"

#include <proto/bsdsocket.h>

#include <iomanip>
#include <iostream>

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        std::cout << "Usage: " << argv[0] << " <http.host.name/path.to.resource>" << std::endl
                  << "e.g.: " << argv[0] << " aminet.net/tree?path=biz" << std::endl;
        return 1;
    }

    std::string arg = argv[1];
    auto pos = arg.find("/");
    std::string hostName = arg.substr(0, pos), resource = pos == std::string::npos ? "/" : arg.substr(pos);

    // bsdsocket.library scope (open/close)
    BSDSocketBaseScope bsdSocketBaseScope;

    auto bsdSocketLibBase = bsdSocketBaseScope.get();
    std::cout << bsdSocketLibBase->lib_Node.ln_Name << " version: " << bsdSocketLibBase->lib_Version
              << " revision: " << bsdSocketLibBase->lib_Revision << std::endl;

    // get protocol info
    auto protocol = (protoent *)getprotobyname("tcp");
    if (protocol == nullptr)
    {
        std::cerr << "Cannot find tcp protocol!" << std::endl;
        return 1;
    }

    std::cout << "Official protocol name: '" << protocol->p_name << "' protocol: " << protocol->p_proto << std::endl;

    // socket scope (open/close)
    SocketScope socketScope(AF_INET, SOCK_STREAM, protocol->p_proto);

    // configure IP and port
    sockaddr_in serverAddress;
    long port = 80;
    hostent *hostEntry;

    // get IP address
    hostEntry = gethostbyname((STRPTR)hostName.c_str());
    if (hostEntry == nullptr)
    {
        std::cerr << "Error getting IP address of host '" << hostName << "'!" << std::endl;
        return 1;
    }

    // IP for host name
    std::string ipAddress = Inet_NtoA((*(in_addr *)(hostEntry->h_addr_list[0])).s_addr);
    std::cout << "Host ip address '" << hostEntry->h_name << "' length = " << hostEntry->h_length << " ip = " << ipAddress << std::endl;

    sockaddr_in hostAddr;
    memset(&hostAddr, 0, sizeof(hostAddr));

    hostAddr.sin_addr.s_addr = inet_addr((STRPTR)ipAddress.c_str());
    hostAddr.sin_port = htons(port);
    hostAddr.sin_family = AF_INET;

    // initiate a connection on a socket
    auto connectionResult = connect(socketScope.get(), (sockaddr *)&hostAddr, sizeof(hostAddr));
    if (connectionResult != 0)
    {
        std::cerr << "Error connecting to host!" << std::endl
                  << " Error code: " << connectionResult << std::endl
                  << std::setfill('0') << std::setw(2) << std::hex << static_cast<int>(hostAddr.sin_len) << std::endl
                  << static_cast<int>(hostAddr.sin_family) << std::endl;
        for (auto i = 0; i < sizeof(sockaddr::sa_data); i++)
            std::cerr << static_cast<int>(((sockaddr *)&hostAddr)->sa_data[i]) << std::endl;

        return 1;
    }

    std::cout << "Connection established." << std::endl << std::endl;

    std::string requestHeaders
        = "GET " + resource + " HTTP/1.1\r\nHost: " + hostName + "\r\n" + "User-Agent: " + argv[0] + " \r\n" + "Accept: */*\r\n\r\n";
    long msgLen = 0, msgToDoLen = requestHeaders.length(), msgOffset = 0;

    std::cout << "Request HEADERS:" << std::endl << requestHeaders << std::endl;

    // GET
    do
    {
        msgLen = send(socketScope.get(), (APTR)(requestHeaders.c_str() + msgOffset), msgToDoLen, 0);
        if (msgLen == -1)
        {
            std::cerr << "Error sending message!" << std::endl;
            return 1;
        }
        if (msgLen > 0)
        {
            msgOffset += msgLen;
            msgToDoLen -= msgLen;
        }
    } while ((msgLen > 0) && (msgToDoLen > 0));

    // response
    std::string fullResponse, responseHeaders;
    bool responseHeadersDetected = false;
    bool transferEncodingChunked = false;
    size_t bufferSize = 4096;
    std::unique_ptr<char[]> buffer(new char[bufferSize]);

    std::cout << "Response:" << std::endl;

    do
    {
        msgLen = recv(socketScope.get(), (APTR)buffer.get(), bufferSize - 1, 0);
        if (msgLen == -1)
        {
            std::cerr << "Error receiving response!" << std::endl;
            return 1;
        }

        if (msgLen > 0)
        {
            std::cout << "@@ " << msgLen << " bytes read ... " << std::endl;
            buffer[msgLen] = '\0';
            fullResponse += buffer.get();

            if (!responseHeadersDetected)
            {
                auto pos = fullResponse.find("\n\r");
                if (pos != std::string::npos)
                {
                    responseHeadersDetected = true;
                    responseHeaders = fullResponse.substr(0, pos + 2);
                    std::cout << "Response HEADERS:" << std::endl << responseHeaders << std::endl;

                    // detect 404
                    auto pos404 = responseHeaders.find("404 Not Found");
                    if (pos404 != std::string::npos)
                        break;

                    // detect 'chunked'
                    auto posChunked = responseHeaders.find("Transfer-Encoding: chunked");
                    transferEncodingChunked = posChunked != std::string::npos;
                    fullResponse = fullResponse.substr(pos + 2); // remove headers
                }
            }

            // very simple detection(s) of the end
            if (fullResponse.length() >= 7 && fullResponse.substr(fullResponse.length() - std::string("</html>").length()) == "</html>")
                break;
            if (transferEncodingChunked)
            {
                if (fullResponse.length() >= 5 && fullResponse.substr(fullResponse.length() - 5) == "0\r\n\r\n")
                    break;
            }
            else if (fullResponse.length() >= 2 && fullResponse.substr(fullResponse.length() - 2) == "\r\n")
                break;
        }
    } while (msgLen > 0);

    // postprocess response message
    if (transferEncodingChunked)
    {
        std::string posprocessedResponse;
        unsigned long chunkSize;
        std::size_t pos = 0;

        do
        {
            std::cout << "pos: " << pos << std::endl;
            pos = fullResponse.find_first_of("0123456789abcdf", pos);
            if (pos == std::string::npos)
            {
                std::cerr << "Error postprocessing chunked response!" << std::endl;
                return 1;
            }
            auto posEnd = fullResponse.find("\r\n", pos);

            // convert hex to number
            std::stringstream ss;
            ss << std::hex << fullResponse.substr(pos, posEnd - pos);
            ss >> chunkSize;

            std::cout << "@@ chunkSize: " << chunkSize << std::endl;
            posprocessedResponse += fullResponse.substr(posEnd + 2, chunkSize);
            pos = posEnd + 2 + chunkSize;
        } while (chunkSize > 0);

        std::cout << "RESPONSE CONTENT:" << std::endl << posprocessedResponse << std::endl;
    }
    else
        std::cout << fullResponse << std::endl;

    return 0;
}
