// INCLUDES ///////////////////////////////////////////////////////////////////

#include <cstdio>
#include <iostream>

#include "net.h"
#include "globals.h"

////////////////////////////////////////////////////////////////////////////////

using std::cerr;
using std::cout;
using std::endl;

namespace eversion {
	namespace net {


// FUNCTIONS //////////////////////////////////////////////////////////////////


void net_data::set_data(data_t t, u32 l,const char* d)
{
	std::memcpy(get_data(),d,l);
	set_len(l);
	set_type(t);
}

///////////////////////////////////////////////////////////////////////////////

void net_client::init()
{
	*name = '\0';
	active = false;
	tcp_sock = NULL;
}

void net_client::free()
{
	if(tcp_sock)
		SDLNet_TCP_Close(tcp_sock);
	init();
}

void net_client::set(char *n, TCPsocket s)
{
	std::strcpy(name,n);
	tcp_sock = s;
}

///////////////////////////////////////////////////////////////////////////////


void net_entity::init()
{
	type = NONE;
	tcp_sock = NULL;
	socket_set = NULL;
	handlefunc = NULL;
	sendfunc = NULL;
	*name = '\0';
}

void net_entity::free()
{

	if ( tcp_sock != NULL )
	{
		net_data data(net_data::DISCONNECT);
		send(data);

		SDLNet_TCP_DelSocket(socket_set,tcp_sock);
		SDLNet_TCP_Close(tcp_sock);

		cout<<"net_entity::free: connection closed"<<endl;
	}

	if ( socket_set != NULL )
		SDLNet_FreeSocketSet(socket_set);

	if(type == SERVER)
	{
		for(size_t i=0; i<max_clients; ++i)
			clients[i].free();
	}

	init();
}

// common function to process data package for all users
void net_entity::proc_data(net_data &data) const
{
	switch(data.get_type())
	{

	}
}

int net_entity::tcp_send_data(TCPsocket dst_sock, net_data &data) const
{

	int sent = SDLNet_TCP_Send(dst_sock,data.get_buffer(),data.get_total_len());

	if(sent<=0)
	{
		//fatal?
		cerr<<"net_entity::send_data: error occured in SDLNet_TCP_Send"<<endl;
		return -1;
	}

	if ((u32)sent < data.get_total_len())
	{
		//fatal?
		cerr<<"net_entity::send_data: SDLNet_TCP_Send returned unexpected value ("<<sent<<")"<<endl;
		return -1;
	}

	return sent;
}

int net_entity::tcp_rcv_data(TCPsocket src_sock, net_data &data)
{
	int recieved =  SDLNet_TCP_Recv(src_sock, data.get_buffer(), max_data_len);

	if(recieved <= 0)
	{
		//fatal
		cerr<<"net_entity::rcv_data: error occured in SDLNet_TCP_Recv"<<endl;
		free();
		return -1;
	}

	data.fix_header();

	if ((u32)recieved < data.get_len())
	{
		//fatal
		cerr<<"net_entity::send_data: SDLNet_TCP_Recv returned unexpected value ("<<recieved<<")"<<endl;
		free();
		return -1;
	}

	return recieved;
}

int net_entity::check_sockets(u32 t) const
{
	int num_ready = SDLNet_CheckSockets(socket_set, t);

	if(num_ready == -1)
	{
		cerr<<"net_entity::check_sockets: SDLNet_CheckSockets returned -1: "<<endl;
	}

	return num_ready;
}

int net_entity::connect(char *host_adr, u16 port)
{
	free();

	socket_set = SDLNet_AllocSocketSet(1);

	if(socket_set == NULL)
	{
		cerr<<"net_entity::connect: SDLNet_AllocSocketSet failed: "<<SDLNet_GetError()<<endl;
	}

	if(SDLNet_ResolveHost(&ip_adr,host_adr,port) == -1)
	{
		cerr<<"net_entity::connect: SDLNet_ResolveHost failed: "<<SDLNet_GetError()<<endl;
		return -1;
	}

	tcp_sock = SDLNet_TCP_Open(&ip_adr);

	if(tcp_sock == NULL)
	{
		cerr<<"net_entity::connect: SDLNet_TCP_Open failed: "<<SDLNet_GetError()<<endl;
		free();
		return -1;
	}

	if(SDLNet_TCP_AddSocket(socket_set,tcp_sock) == -1)
	{
		cerr<<"net_entity::connect: SDLNet_TCP_AddSocket failed: "<<SDLNet_GetError()<<endl;
		free();
		return -1;
	}

	//send a connection request messsage to server & wait for reply
	net_data data;
	data.set_data(net_data::NEW_CLI,strlen(name)+1,name);

	send_cli(data);
	int num_ready_sockets = check_sockets(10000);	//wait 10 sec for reply from the server

	if(num_ready_sockets>0 && srv_isready())
	{
		if(rcvfrom_srv(data) > 0)
		{
			if(data.get_type() == net_data::POSITIVE)
			{
				cout<<"net_entity::connect: connection established"<<endl;
			}
			else
			{
				cerr<<"net_entity::connect: server refused the connection request"<<endl;
				free();
				return -1;
			}
		}
		else
		{
			cerr<<"net_entity::connect: invalid/corrupted packet recieved"<<endl;
			free();
			return -1;
		}

	}
	else
	{
		cerr<<"net_entity::connect: timeout, server is not responding"<<endl;
		free();
		return -1;
	}

	type = CLIENT;
	handlefunc = &net_entity::handle_cli;
	sendfunc =  &net_entity::send_cli;

	return 0;
}


int net_entity::serve(u16 port)
{
	free();

	socket_set = SDLNet_AllocSocketSet(max_clients+1);

	if(socket_set == NULL)
	{
		cerr<<"net_entity::connect: SDLNet_AllocSocketSet failed: "<<SDLNet_GetError()<<endl;
	}

	if(SDLNet_ResolveHost(&ip_adr,NULL,port) == -1)
	{
		cerr<<"net_entity::connect: SDLNet_ResolveHost failed: "<<SDLNet_GetError()<<endl;
		free();
		return -1;
	}

	tcp_sock = SDLNet_TCP_Open(&ip_adr);

	if(tcp_sock == NULL)
	{
		cerr<<"net_entity::serve: SDLNet_TCP_Open failed: "<<SDLNet_GetError()<<endl;
		free();
		return -1;
	}
	else
	{
		cout<<"net_entity::serve: succesfully started server:"<<ip_adr.host<<":"<<ip_adr.port<<endl;
	}

	SDLNet_TCP_AddSocket(socket_set,tcp_sock);

	type = SERVER;
	handlefunc = &net_entity::handle_srv;
	sendfunc =  &net_entity::send_srv;

	return 0;
}


void net_entity::handle_srv()
{
	int num_ready_sockets = check_sockets(10);

	if(srv_isready())	//new client
	{
		--num_ready_sockets;
		TCPsocket cli_sock = SDLNet_TCP_Accept(tcp_sock);

		if(cli_sock == NULL)
		{
			cerr<<"net_entity::handle_srv: SDLNet_TCP_Open failed: "<<SDLNet_GetError()<<endl;
			return;
		}

		net_data data;
		if(tcp_rcv_data(cli_sock,data) <= 0)
		{
			cerr<<"net_entity::handle_srv: rcv_data failed: "<<SDLNet_GetError()<<endl;
			SDLNet_TCP_Close(cli_sock);
			return;
		}

		if(data.get_type() == net_data::NEW_CLI)
		{
			int cli = add_cli(cli_sock,data);
			if( cli == -1)
			{
				SDLNet_TCP_Close(cli_sock);
			}
			else
			{
				data.set_type(net_data::POSITIVE);
				sendto_cli(static_cast<size_t>(cli),data);
			}
		}
		else
		{
			cerr<<"net_entity::handle_srv: not a valid new client request ("
				<<data.get_type()<<")"<<endl;
			SDLNet_TCP_Close(cli_sock);
		}
	}

	for(size_t i=0; num_ready_sockets && i<max_clients; i++)
	{
		net_data data;

		if( clients[i].active &&  sock_ready(clients[i].tcp_sock) )
		{
			--num_ready_sockets;
			rcvfrom_cli(i,data);

			if(data.get_type() == net_data::DISCONNECT)
			{
				remove_cli(i);
			}
			else
			{
				send(data);
				proc_data(data);
			}
		}
	}
}

void net_entity::handle_cli()
{
	int num_ready_sockets = check_sockets(10);

	if(num_ready_sockets && srv_isready())
	{
		net_data data;
		rcvfrom_srv(data);

		if(data.get_type() == net_data::DISCONNECT)
		{
			free();
			cerr<<"net_entity::handle_cli: server disconnected"<<endl;
		}
		else
		{
			proc_data(data);
		}

	}
	else
	{
		//no package sent
		//cerr<<"net_entity::handle_cli: server not ready"<<endl;
	}
}

int net_entity::remove_cli(size_t i)
{
	int num_used_sockets = SDLNet_TCP_DelSocket(socket_set,clients[i].tcp_sock);

	if(num_used_sockets<0)
		cerr<<"net_entity::remove_cli: SDLNet_DelSocket returned "<<num_used_sockets;
	else
	{
		clients[i].free();
		cout<<"net_entity::remove_cli: user #"<<i<<" removed"<<endl;
	}

	return num_used_sockets;
}

int net_entity::add_cli(TCPsocket cli_sock, net_data &data)
{
	for(u32 i=0; i<max_clients; i++)
	{
		if (clients[i].active==false)
		{
			clients[i].active = true;
			clients[i].tcp_sock = cli_sock;
			strcpy(clients[i].name,data.get_data());
			SDLNet_TCP_AddSocket(socket_set,cli_sock);
			return i;
		}
	}

	cerr<<"net_entity::add_cli: no room for a new client"<<endl;
	return -1;
}

// server's send function
void net_entity::send_srv(net_data &data) const
{
	for(size_t i=0; i<max_clients; i++)
	{
		if (clients[i].active)
			sendto_cli(i,data);
	}

	//mimic sending to self
	proc_data(data);
}


///////////////////////////////////////////////////////////////////////////////

	}

}

////////////////////////////////////////////////////////////////////////////////
