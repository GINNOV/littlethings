#ifndef EVERSION__NET_H
# define EVERSION__NET_H


// INCLUDES ///////////////////////////////////////////////////////////////////

# include <SDL/SDL_net.h>
# include <cstring>
# include "types.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {
	namespace net {

// CLASSES ////////////////////////////////////////////////////////////////////

/**
    @author f(Dark Angel)
    @date   9/3/2004
*/

/*
	todo:
	-UDP transfers
	-dynamic memory (performance-- ?)
*/

const u32 max_clients = 7, max_data_len = 32;

struct net_data {
public:
	enum  data_t { NONE, POSITIVE, NEGATIVE, DISCONNECT, NEW_CLI, ROL, ROR };

	inline void init() { set_type(NONE); set_len(0); }

	inline char *get_buffer() const { return (char*)buffer; }
	inline char *get_data() const { return (char*)(buffer+sizeof(u16)+sizeof(u32)); }
	void set_data(data_t,u32,const char*);

	inline void fix_header() { type = SDLNet_Read16(buffer); len = SDLNet_Read32(buffer+sizeof(u16)); }

	inline u32 get_len() const { return len; }
	inline u32 get_total_len() const { return len+sizeof(u16)+sizeof(u32); }

	inline u16 get_type() const { return type; }
	inline void set_type(data_t t) { type=t; SDLNet_Write16(type,buffer); }


	inline net_data() { init(); }
	inline net_data(data_t t) { init(); set_type(t); }

protected:
	inline void set_len(u32 l) { len=l; SDLNet_Write32(len,buffer+sizeof(u16)); }

private:
	u16 type;
	u32 len;
	char buffer[max_data_len+sizeof(u16)+sizeof(u32)];	//format: type-buffer-data
	//char buffer;
};


struct net_client {
	bool		active;
	TCPsocket	tcp_sock;
	char		name[max_data_len];
	/*u32	id;
	u32		state;*/

	void set(char*, TCPsocket);

	void init();
	void free();

	net_client() { init(); };
	net_client(char *n, TCPsocket s) { set(n,s); }
	~net_client() { free(); };
};


class net_entity
{
public:
	typedef enum user_t { NONE, SERVER, CLIENT };

	inline net_entity();
	inline ~net_entity();

	// Interface Functions
	inline bool is_valid();
	inline void proc();
	inline void send(net_data&);
	//server-only
	int  serve(u16);
	//client-only
	int  connect(char*,u16);

	inline void set_name(const char*);
	inline const char* get_name() const;

private:
	// Internal Functions
	void init();
	void free();

	int  check_sockets(u32) const;
	void proc_data(net_data &data) const;
	int  tcp_send_data(TCPsocket,net_data&) const;
	int  tcp_rcv_data(TCPsocket,net_data&);
	bool sock_ready(TCPsocket) const;

	// client-only
	inline void send_cli(net_data&) const;
	inline int  rcvfrom_srv(net_data&);
	inline bool srv_isready() const;
	void handle_cli();
	// server-only
	void send_srv(net_data&) const;
	inline int  sendto_cli(size_t,net_data&) const;
	inline int  rcvfrom_cli(size_t,net_data&);
	bool cli_isready(u32) const;
	int  add_cli(TCPsocket,net_data&);
	int  remove_cli(size_t);
	void handle_srv();


	// Members
	void (net_entity::*handlefunc)();
	void (net_entity::*sendfunc)(net_data&) const;

	IPaddress		ip_adr;
	TCPsocket		tcp_sock;	// server<->client init socket
	SDLNet_SocketSet	socket_set;
	user_t			type;
	char			name[max_data_len];

	// server-only
	net_client clients[max_clients];
};

// inline functions:
inline net_entity::net_entity() { init(); }
inline net_entity::~net_entity() { free(); }

inline bool net_entity::is_valid() { return type==SERVER || type==CLIENT; }
inline void net_entity::send(net_data &data) { (this->*sendfunc)(data); }
inline void net_entity::proc() { (this->*handlefunc)(); }

inline bool net_entity::sock_ready(TCPsocket s) const
{ return SDLNet_SocketReady(s); }

inline void net_entity::set_name(const char* n) { std::strcpy(name,n); }
inline const char* net_entity::get_name() const { return name; }

// client-only
inline void net_entity::send_cli(net_data &data) const
{ tcp_send_data(tcp_sock,data); }

inline int net_entity::rcvfrom_srv(net_data &data)
{ return tcp_rcv_data(tcp_sock, data); }

inline bool net_entity::srv_isready() const
{ return sock_ready(tcp_sock); }

// server-only
inline int net_entity::sendto_cli(size_t index, net_data &data) const
{ return tcp_send_data(clients[index].tcp_sock,data); }

inline int net_entity::rcvfrom_cli(size_t index, net_data &data)
{ return tcp_rcv_data(clients[index].tcp_sock, data); }


////////////////////////////////////////////////////////////////////////////////

	}

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__NET_H
