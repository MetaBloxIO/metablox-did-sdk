#ifndef __DID_WALLET_H__
#define __DID_WALLET_H__

#include "did.h"

typedef void* wallet_handle;

typedef struct wallet_did_namelist{
int         count;
char**   names;
}wallet_did_nl;

#ifdef __cplusplus
extern "C" {
#endif 

wallet_handle   wallet_handle_create(const char* name, const char* path);
void            wallet_handle_destroy(wallet_handle handle);

int             wallet_store_did(wallet_handle wallet, did_handle did, const char* name, const char* password);
did_handle      wallet_load_did(wallet_handle wallet, const char* name, const char* password); 

int             wallet_change_name(wallet_handle wallet,const char* oldname,const char* newname);
int             wallet_change_password(wallet_handle wallet,const char* name,const char* oldpassword,const char* newpassword);
int              wallet_get_namelist(wallet_handle wallet,wallet_did_nl * data);
void            did_wallet_free_namelist(wallet_did_nl* namelist);

#ifdef __cplusplus
}
#endif 

#endif 
