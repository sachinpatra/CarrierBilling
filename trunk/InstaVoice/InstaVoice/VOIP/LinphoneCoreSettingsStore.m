/* LinphoneCoreSettingsStore.m
 *
 * Modified by Pandian for InstaVoice client, June, 2017.
 *
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "LinphoneCoreSettingsStore.h"
#import "Setting.h"
#import "Log.h"
#import "Logger.h"
#import "VoipSetting.h"
#import "Common.h"
#include "linphone/linphone_tunnel.h"
#include "linphone/lpconfig.h"
#include <stdio.h>
#include <stdlib.h>

#define TRANSPORT_UDP   @"udp"
#define TRANSPORT_TCP   @"tcp"

#define kRegistrationExpiryTime   600  //in seconds
#define kMaxRegsitrationRetry       8

//- default ports to be used
#define kTcpPort   5228
#define KUdpPort   5060

//- Uncomment the following to register this UA SIP client with the local sip proxy
//
//#define FORIEGN_SIP_PROXY
//#define IMS_CLIENT

#ifdef IMS_CLIENT
#define kPreferredIdentity @"P-Preferred-Identity"
#endif

static LinphoneCoreSettingsStore* lpCoreSettings = nil;

@interface LinphoneCoreSettingsStore()

#ifdef IMS_CLIENT
@property (atomic) NSString* privateId;
@property (atomic) NSString* pCSCFHost;
@property (atomic) int pCSCFPort;
#endif
@property (atomic) NSString* serverHost; //IP address of reachMe server
@property (atomic) NSString* transport;
@property (atomic) int portTCP;
@property (atomic) int portUDP;
@property (atomic) NSInteger registrationStatus;
@property (atomic) BOOL isRmsIPAddressChanged;
@end



@implementation LinphoneCoreSettingsStore

+(LinphoneCoreSettingsStore *)sharedLinphoneCoreSettingsStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lpCoreSettings = [[LinphoneCoreSettingsStore alloc]init];
    });
    KLog(@"LinphoneCoreSettingsStore: %p",lpCoreSettings);
    return lpCoreSettings;
}

- (id)init {
	self = [super init];
	if (self) {
		dict = [[NSMutableDictionary alloc] init];
		changedDict = [[NSMutableDictionary alloc] init];
        voipInfo = [VoipSetting sharedVoipSetting].voipInfo;
        self.natType = NATType_unknown;
        //July 23, 2018
        self.publicIPAddr = @"";
        self.publicPort = @"";
        //
        self.transport = TRANSPORT_TCP;
        self.portTCP = kTcpPort;
        self.portUDP = KUdpPort;
        self.serverHost = @"";
#ifdef IMS_CLIENT
        self.privateId = @"<alice@open-ims.test>";
        self.pCSCFHost = @"34.209.1.60";
        self.pCSCFPort = KUdpPort;
#endif
        
        self.isRmsIPAddressChanged = NO;
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(registrationUpdateEvent:)
                                                   name:kLinphoneRegistrationUpdate
                                                 object:nil];
        
#ifdef FORIEGN_SIP_PROXY
        /*
        voipInfo = [[SettingModelVoip alloc] init];
        voipInfo.serverUrl = @"sip.linphone.org"; //@"54.148.51.116";
        voipInfo.serverPort = 5060;
        voipInfo.userName = @"marudhu";//@"19086566050";
        voipInfo.password = @"sivaganga";//@"123";
        */
        /*
        voipInfo = [[SettingModelVoip alloc] init];
        voipInfo.serverUrl = @"stagingreachme.instavoice.com";
        voipInfo.serverPort = 5060;//not used
        voipInfo.userName = @"918197277306";
        voipInfo.password = @"123";
        */
        voipInfo = [[SettingModelVoip alloc] init];
        voipInfo.serverUrl = @"open-ims.test";
        voipInfo.serverPort = 4060;//not used
        voipInfo.userName = @"alice";
        voipInfo.password = @"alice";
#endif

	}
	return self;
}

#pragma mark --- Private Methods

- (void)setCString:(const char *)value forKey:(NSString *)key {
	id obj = @"";
	if (value)
		obj = [[NSString alloc] initWithCString:value encoding:NSUTF8StringEncoding];
	[self setObject:obj forKey:key];
}

- (NSString *)stringForKey:(NSString *)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)value forKey:(NSString *)key {
	[dict setValue:value forKey:key];
	[changedDict setValue:[NSNumber numberWithBool:TRUE] forKey:key];
}

- (id)objectForKey:(NSString *)key {
	return [dict valueForKey:key];
}

- (BOOL)valueChangedForKey:(NSString *)key {
	return [[changedDict valueForKey:key] boolValue];
}

+ (int)validPort:(int)port {
	if (port < 0) {
		return 0;
	}
	if (port > 65535) {
		return 65535;
	}
	return port;
}

+ (BOOL)parsePortRange:(NSString *)text minPort:(int *)minPort maxPort:(int *)maxPort {
	
    NSError *error = nil;
	*minPort = -1;
	*maxPort = -1;
	NSRegularExpression *regex =
		[NSRegularExpression regularExpressionWithPattern:@"([0-9]+)(([^0-9]+)([0-9]+))?" options:0 error:&error];
	if (error != NULL)
		return FALSE;
	NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
	if ([matches count] == 1) {
		NSTextCheckingResult *match = [matches objectAtIndex:0];
		bool range = [match rangeAtIndex:2].length > 0;
		if (!range) {
			NSRange rangeMinPort = [match rangeAtIndex:1];
			*minPort = [LinphoneCoreSettingsStore validPort:[[text substringWithRange:rangeMinPort] intValue]];
			*maxPort = *minPort;
			return TRUE;
		} else {
			NSRange rangeMinPort = [match rangeAtIndex:1];
			*minPort = [LinphoneCoreSettingsStore validPort:[[text substringWithRange:rangeMinPort] intValue]];
			NSRange rangeMaxPort = [match rangeAtIndex:4];
			*maxPort = [LinphoneCoreSettingsStore validPort:[[text substringWithRange:rangeMaxPort] intValue]];
			if (*minPort > *maxPort) {
				*minPort = *maxPort;
			}
			return TRUE;
		}
	}
	int err;

	err = sscanf(text.UTF8String, "%i - %i", minPort, maxPort);
	if (err == 0) {
		*minPort = *maxPort = -1;
	} else if (err == 1) {
		*maxPort = -1;
	}

	// Minimal port allowed
	if (*minPort < 1024) {
		*minPort = -1;
	}
	// Maximal port allowed
	if (*maxPort > 65535) {
		*maxPort = -1;
	}
	// minPort must be inferior or equal to maxPort
	if (*minPort > *maxPort) {
		*maxPort = *minPort;
	}

	return TRUE;
}

- (void)transformCodecsToKeys:(const MSList *)codecs {

	const MSList *elem = codecs;
	for (; elem != NULL; elem = elem->next) {
		PayloadType *pt = (PayloadType *)elem->data;
		NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
		if (pref) {
			bool_t value = linphone_core_payload_type_enabled(LC, pt);
			[self setBool:value forKey:pref];
		} else {
			LOGW(@"Codec %s/%i supported by core is not shown in iOS app config view.", pt->mime_type, pt->clock_rate);
		}
	}
}

- (void)transformAccountToKeys:(NSString *)username {
    
	const MSList *proxies = linphone_core_get_proxy_config_list(LC);
	while (username && proxies &&
		   strcmp(username.UTF8String,
				  linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data))) != 0) {
		proxies = proxies->next;
	}
	LinphoneProxyConfig *proxy = NULL;

	// default values
	{
		[self setBool:NO forKey:@"account_pushnotification_preference"];
		[self setObject:@"" forKey:@"account_mandatory_username_preference"];
		[self setObject:@"" forKey:@"account_mandatory_domain_preference"];
		[self setCString:"" forKey:@"account_display_name_preference"];
		[self setObject:@"" forKey:@"account_proxy_preference"];
        [self setObject:self.transport forKey:@"account_transport_preference"];
		[self setBool:NO forKey:@"account_outbound_proxy_preference"];
		[self setBool:NO forKey:@"account_avpf_preference"];
		[self setBool:YES forKey:@"account_is_default_preference"];
		[self setBool:YES forKey:@"account_is_enabled_preference"];
		[self setCString:"" forKey:@"account_userid_preference"];
		[self setCString:"" forKey:@"account_mandatory_password_preference"];
		[self setCString:"" forKey:@"ha1_preference"];
		[self setInteger:-1 forKey:@"account_expire_preference"];
		[self setInteger:-1 forKey:@"current_proxy_config_preference"];
		[self setCString:"" forKey:@"account_prefix_preference"];
		[self setBool:NO forKey:@"account_substitute_+_by_00_preference"];
	}

	if (proxies) {
		proxy = proxies->data;
		// root section
		{
			const char *refkey = linphone_proxy_config_get_ref_key(proxy);
			if (refkey) {
				BOOL pushEnabled = (strcmp(refkey, "push_notification") == 0);
				[self setBool:pushEnabled forKey:@"account_pushnotification_preference"];
			}
			const LinphoneAddress *identity_addr = linphone_proxy_config_get_identity_address(proxy);
			if (identity_addr) {
				const char *server_addr = linphone_proxy_config_get_server_addr(proxy);
				LinphoneAddress *proxy_addr = linphone_core_interpret_url(LC, server_addr);
				int port = linphone_address_get_port(proxy_addr);

				[self setCString:linphone_address_get_username(identity_addr)
						  forKey:@"account_mandatory_username_preference"];
				[self setCString:linphone_address_get_display_name(identity_addr)
						  forKey:@"account_display_name_preference"];
				[self setCString:linphone_address_get_domain(identity_addr)
						  forKey:@"account_mandatory_domain_preference"];
				if (strcmp(linphone_address_get_domain(identity_addr), linphone_address_get_domain(proxy_addr)) != 0 ||
					port > 0) {
					char tmp[256] = {0};
					if (port > 0) {
						snprintf(tmp, sizeof(tmp) - 1, "%s:%i", linphone_address_get_domain(proxy_addr), port);
					} else
						snprintf(tmp, sizeof(tmp) - 1, "%s", linphone_address_get_domain(proxy_addr));
					[self setCString:tmp forKey:@"account_proxy_preference"];
				}
				const char *tname = [self.transport UTF8String];
				switch (linphone_address_get_transport(proxy_addr)) {
					case LinphoneTransportTcp:
						tname = "tcp";
						break;
					case LinphoneTransportTls:
						tname = "tls";
						break;
					default:
						break;
				}
				linphone_address_unref(proxy_addr);
				[self setCString:tname forKey:@"account_transport_preference"];
			}

			[self setBool:(linphone_proxy_config_get_route(proxy) != NULL) forKey:@"account_outbound_proxy_preference"];
			[self setBool:linphone_proxy_config_avpf_enabled(proxy) forKey:@"account_avpf_preference"];
			[self setBool:linphone_proxy_config_register_enabled(proxy) forKey:@"account_is_enabled_preference"];
			[self setBool:(linphone_core_get_default_proxy_config(LC) == proxy)
				   forKey:@"account_is_default_preference"];

			const LinphoneAuthInfo *ai = linphone_core_find_auth_info(
				LC, NULL, [self stringForKey:@"account_mandatory_username_preference"].UTF8String,
				[self stringForKey:@"account_mandatory_domain_preference"].UTF8String);
			if (ai) {
				[self setCString:linphone_auth_info_get_userid(ai) forKey:@"account_userid_preference"];
				[self setCString:linphone_auth_info_get_passwd(ai) forKey:@"account_mandatory_password_preference"];
				// hidden but useful if provisioned
				[self setCString:linphone_auth_info_get_ha1(ai) forKey:@"ha1_preference"];
			}

			int idx = (int)bctbx_list_index(linphone_core_get_proxy_config_list(LC), proxy);
			[self setInteger:idx forKey:@"current_proxy_config_preference"];

			int expires = linphone_proxy_config_get_expires(proxy);
			[self setInteger:expires forKey:@"account_expire_preference"];
		}

		// call section
		{
			const char *dial_prefix = linphone_proxy_config_get_dial_prefix(proxy);
			[self setCString:dial_prefix forKey:@"account_prefix_preference"];
			BOOL dial_escape_plus = linphone_proxy_config_get_dial_escape_plus(proxy);
			[self setBool:dial_escape_plus forKey:@"account_substitute_+_by_00_preference"];
		}
	}
}

- (void)alertAccountError:(NSString *)error {
	UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
																	 message:error
															  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}];
	
	[errView addAction:defaultAction];
	//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
}

-(void)synchronizeAccounts {
    
    KLog(@"synchronizeAccounts");
    EnLogd(@"synchronizeAccounts");
    
    LinphoneCore *lc = [LinphoneManager getLc];
    if(nil==lc) {
        KLog1(@"Error getting LinphoneManager");
        return;
    }
    
    if(nil == voipInfo) {
        KLog(@"FIXEME: voipInfo is null");
        EnLogd(@"FIXEME: voipInfo is null");
        return;
    }
    
    [[LinphoneManager instance] removeAllAccounts];
    
    NSString* userName = [self userName];
    NSString* password = [self password];
    KLog(@"password:%@",password);
    NSString* domain = [self accountDomain];
    
    if(!userName.length || !domain.length || !password.length) {
        KLog(@"WARNING: UserName/password/domain is not configured. Returns.");
        EnLogd(@"WARNING: UserName/password/domain is not configured. Returns.");
        return;
    }
    
    LinphoneAddress *sipAddr = linphone_core_interpret_url(lc,
                                                [[NSString stringWithFormat:@"sip:%@@%@", userName, domain] UTF8String]);
    
    //linphone_address_set_header(sipAddr, "X-Create-Account", "yes");
    //DEC 2017
    if(!sipAddr) {
        KLog(@"WARNING: sipAddr should not be null. Returns.");
        EnLogd(@"WARNING: sipAddr should not be null. Returns.");
        return;
    }
    
    LinphoneSipTransports tr;
    memset(&tr,0,sizeof(tr));
    int port=0;
    //
    if([self.transport isEqualToString:TRANSPORT_UDP]) {
        linphone_address_set_transport(sipAddr, LinphoneTransportUdp);
        if(self.portUDP>0) {
            /*
            linphone_address_set_port(sipAddr, self.portUDP);
            linphone_core_set_sip_port(lc, self.portUDP);
            linphone_transports_set_udp_port(tr, self.portUDP);
            linphone_transports_set_tcp_port(tr, 0);
            */
            tr.udp_port = self.portUDP;
            port = self.portUDP;
        }
    }
    else {
        linphone_address_set_transport(sipAddr, LinphoneTransportTcp);
        //- Pass 0 for port param to use default port 5060 or to use if port present in DNS SRV response
        if(self.portTCP>0) {
            /*
            linphone_address_set_port(sipAddr, self.portTCP);
            linphone_core_set_sip_port(lc, self.portTCP);
            linphone_transports_set_tcp_port(tr, self.portTCP);
            linphone_transports_set_udp_port(tr, 0);
            */
            
            tr.tcp_port = self.portTCP;
            port = self.portTCP;
        }
    }
    
    /*FEB, 2018
    KLog(@"transport = %@, port = %d",self.transport, port);
    EnLogd(@"transport = %@, port = %d",self.transport, port);
    */
    
    //JULY 19, 2018 linphone_core_set_sip_transports(lc,&tr);
    LinphoneSipTransports transportValue = {-1, -1, -1, -1};
    linphone_core_set_sip_transports(lc, &transportValue);
    //
    linphone_address_set_port(sipAddr, port);
    
    //DEC 18, 2017
    /*
    LinphoneFactory *factory = linphone_factory_get();
    LinphoneTransports *transport = linphone_factory_create_transports(factory);
    linphone_transports_set_udp_port(transport, self.portUDP);
    linphone_transports_set_tcp_port(transport, self.portTCP);
    linphone_transports_set_tls_port(transport, 0);
    linphone_transports_set_dtls_port(transport, 0);
    linphone_core_set_transports(lc,transport);
    linphone_transports_unref(transport);
    */
    //
    
    LinphoneProxyConfig *instaVoiceProxy = linphone_proxy_config_new();
    linphone_proxy_config_set_identity_address(instaVoiceProxy, sipAddr);
    linphone_proxy_config_set_server_addr(instaVoiceProxy, [self accountProxyRoute].UTF8String);
    linphone_proxy_config_set_route(instaVoiceProxy, [self accountProxyRoute].UTF8String);
    linphone_proxy_config_set_ref_key(instaVoiceProxy, "push_notification");
    
    linphone_proxy_config_set_custom_header(instaVoiceProxy,kCustomHdrStatus.UTF8String,[self getNatType].UTF8String);
    linphone_proxy_config_set_custom_header(instaVoiceProxy,kCustomHdrDeviceId.UTF8String,[self getDeviceID].UTF8String);
#ifdef IMS_CLIENT
    linphone_proxy_config_set_custom_header(instaVoiceProxy, kPreferredIdentity.UTF8String, self.privateId.UTF8String);
#endif
    linphone_core_enable_ipv6(LC,  TRUE);
    
    //linphone_address_get_username(sipAddr)
    LinphoneAuthInfo *authInfo = linphone_auth_info_new(userName.UTF8String, NULL,
                                                        password.UTF8String, NULL, NULL,
                                                        linphone_address_get_domain(sipAddr));
    
    linphone_proxy_config_set_expires(instaVoiceProxy, kRegistrationExpiryTime);
    linphone_proxy_config_enable_register(instaVoiceProxy, true);
    linphone_core_add_auth_info(lc, authInfo);
    linphone_core_add_proxy_config(lc, instaVoiceProxy);
    linphone_core_set_default_proxy_config(lc, instaVoiceProxy);
    //TODO [[LinphoneManager instance] configurePushTokenForProxyConfig:instaVoiceProxy];
    
    KLog(@"STUN server: %@",[self stunServer]);
    //July 24, 2018 linphone_core_set_stun_server(LC, [[self stunServer] UTF8String]);
    
    //July 24, 2018
    NSString* stun = [self stunServer];
    if([self stunServer].length) {
        LinphoneNatPolicy *policy = linphone_proxy_config_get_nat_policy(instaVoiceProxy) ?: linphone_core_create_nat_policy(LC);
        linphone_nat_policy_enable_stun(policy, 1); // We always use STUN with ICE
        linphone_nat_policy_enable_ice(policy, 1);
        linphone_nat_policy_set_stun_server(policy, stun.UTF8String);
        linphone_proxy_config_set_nat_policy(instaVoiceProxy, policy);
    }
    //
    
    linphone_proxy_config_unref(instaVoiceProxy);
    linphone_auth_info_destroy(authInfo);
    linphone_address_unref(sipAddr);
    
    /*
    char* fmtp = "fmtp:100 0-15";
    payload_type_set_send_fmtp(&payload_type_telephone_event, fmtp);
    linphone_core_set_text_payload_types(LC, const bctbx_list_t *payload_types)
    */
    /*
    NSString *holdMusicPath = [[NSBundle mainBundle] pathForResource:@"hold16" ofType:@"wav"];
    linphone_core_set_play_file(lc, holdMusicPath.UTF8String);
     */
    //linphone_core_set_use_files(lc,TRUE);
}

- (void)synchronizeCodecs:(const MSList *)codecs {
	PayloadType *pt;
	const MSList *elem;

	for (elem = codecs; elem != NULL; elem = elem->next) {
		pt = (PayloadType *)elem->data;
		NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
		linphone_core_enable_payload_type(LC, pt, [self boolForKey:pref]);
	}
}

- (void)removeAccount {
    
    LinphoneProxyConfig *config = bctbx_list_nth_data(linphone_core_get_proxy_config_list(LC),
                                                      [self integerForKey:@"current_proxy_config_preference"]);
    
    BOOL isDefault = (linphone_core_get_default_proxy_config(LC) == config);
    
    const LinphoneAuthInfo *ai = linphone_proxy_config_find_auth_info(config);
    linphone_core_remove_proxy_config(LC, config);
    if (ai) {
        linphone_core_remove_auth_info(LC, ai);
    }
    [self setInteger:-1 forKey:@"current_proxy_config_preference"];
    
    if (isDefault) {
        // if we removed the default proxy config, set another one instead
        if (linphone_core_get_proxy_config_list(LC) != NULL) {
            linphone_core_set_default_proxy_index(LC, 0);
        }
    }
    [self transformLinphoneCoreToKeys];
}
#pragma mark -

#pragma mark -- Utility methods

-(NSString*) getNatType {
    
    if(NATType_symmetric == self.natType)
        return kNatSymmetric;
    else if(NATType_nonSymmetric == self.natType)
        return kNatNonSymmetric;
    
    return kNatUnknown;
}

-(NSString*) getDeviceID {
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    return deviceID;
}

-(NSString*)getServerHost {
    return [self accountDomain];
}

- (NSString *) myPrimaryNumber {
    NSString* loggedInPhone = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    return [NSString stringWithFormat:@"%@",loggedInPhone];
}

- (NSString*)userName {
    return voipInfo.userName;
}

-(NSString*) password {
    NSString* pwd = voipInfo.password;
    return pwd;
}

-(NSString*) accountDomain {
   
#ifdef IMS_CLIENT
    return self.pCSCFHost;
#endif
    
    if(self.serverHost.length)
        return self.serverHost;
    else
        return voipInfo.serverUrl;
}

-(NSString*) stunServer {
    
    if(self.serverHost.length)
        return self.serverHost;
    else
        return voipInfo.serverUrl;
}

- (NSString *)accountProxyRoute {
    int port = self.portUDP;
    if([self.transport isEqualToString:TRANSPORT_TCP])
        port = self.portTCP;
    
    return [[self accountDomain] stringByAppendingFormat:@":%d;transport=%@",port, self.transport];
}

#pragma mark Utility functions
-(LinphoneAddress *)normalizePhoneAddress:(NSString *)value {
    if (!value) {
        return NULL;
    }
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    const char * normvalue;
    if (linphone_proxy_config_is_phone_number(cfg, value.UTF8String)) {
        normvalue = linphone_proxy_config_normalize_phone_number(cfg, value.UTF8String);
    } else {
        normvalue = value.UTF8String;
    }
    LinphoneAddress *addr = linphone_proxy_config_normalize_sip_uri(cfg, normvalue);
    
    
    // since user wants to escape plus, we assume it expects to have phone numbers by default
    if (addr) {
        if (cfg && (linphone_proxy_config_get_dial_escape_plus(cfg))) {
            if (linphone_proxy_config_is_phone_number(cfg, normvalue)) {
                linphone_address_set_username(addr, normvalue);
            }
        } else {
            if (linphone_proxy_config_is_phone_number(cfg, value.UTF8String)) {
                linphone_address_set_username(addr, value.UTF8String);
            }
        }
    }
    
    return addr;
}

#pragma mark -

#pragma mark --- Public Methods

-(void)setVoipInfo:(SettingModelVoip *)info {
    
    NSString* hostIPAddress = @"";
    
    //- Check if voip_enabled for primary number. If so, get the IP addr from .voipIPAddress
    NSString* primaryNumber = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    VoiceMailInfo *primaryNumberVoiceMailInfo = [[Setting sharedSetting]voiceMailInfoForPhoneNumber:primaryNumber];
    if(primaryNumberVoiceMailInfo) {
        hostIPAddress =  primaryNumberVoiceMailInfo.voipIPAddress;
        KLog(@"VOIP enabled for Primary num %@ and IP addr is %@",primaryNumber, hostIPAddress);
        EnLogd(@"VOIP enabled for Primary num %@ and IP addr is %@",primaryNumber, hostIPAddress);
    }
    
    if(!hostIPAddress.length)
    {
        //- Get the voicemail info of all secondary number numbers that are voip enabled.
        //- Use the first one, if multiple numbers have voip enabled.
        VoiceMailInfo* additionalNumVoiceMailInfo = nil;
        SettingModel *currentSettingsModel = [Setting sharedSetting].data;
        if (currentSettingsModel.voiceMailInfo && [currentSettingsModel.voiceMailInfo count]) {
            for (VoiceMailInfo *voiceMailInfo in currentSettingsModel.voiceMailInfo) {
                if(![voiceMailInfo.phoneNumber isEqualToString:primaryNumber]) {
                    additionalNumVoiceMailInfo = voiceMailInfo;
                    break;
                }
            }
        }
        
        if(nil != additionalNumVoiceMailInfo) {
            hostIPAddress = additionalNumVoiceMailInfo.voipIPAddress;
            KLog(@"VOIP enabled for Addtnl num %@ and IP addr is %@",additionalNumVoiceMailInfo.phoneNumber, hostIPAddress);
            EnLogd(@"VOIP enabled for Addtnl num %@ and IP addr is %@",additionalNumVoiceMailInfo.phoneNumber, hostIPAddress);
        }
    }
    
    /* TEST
     hostIPAddress = @"54.148.51.116:udp:5060:tcp:5228:tcp";
    KLog(@"test-- hostIPAddress=%@",hostIPAddress);
    */
    
    SettingModelVoip *viFromVM = nil;
    if(hostIPAddress.length) {
        viFromVM = [self parseVoipInfoFromString:hostIPAddress];
        if(viFromVM) {
            viFromVM.userName = info.userName;
            viFromVM.password = info.password;
        }
    } else {
        KLog(@"voipInfo is not present in voicemails_info. Use default voipInfo:%@",info.serverUrl);
        EnLogd(@"voipInfo is not present in voicemails_info. Use default voipInfo:%@",info.serverUrl);
    }
    
#ifndef FORIEGN_SIP_PROXY
    if(!viFromVM)
        voipInfo = [[SettingModelVoip alloc]initWithObject:info];
    else
        voipInfo = [[SettingModelVoip alloc]initWithObject:viFromVM];
    
    //- set the current registration info
    if(![self.serverHost isEqualToString:voipInfo.serverUrl] ||
       (self.portTCP != voipInfo.tcpPort) || (self.portUDP != self.portUDP))
        self.isRmsIPAddressChanged = YES;
    
    self.serverHost = voipInfo.serverUrl;
    self.portTCP = voipInfo.tcpPort;
    self.portUDP = voipInfo.udpPort;
    if(voipInfo.priority)
        self.transport = TRANSPORT_TCP;
    else
        self.transport = TRANSPORT_UDP;
    //
    
    KLog(@"voipInfo = %@",voipInfo);
    EnLogd(@"voipInfo = %@",voipInfo);
#endif
    
}

/*
 Returns 1, all or required values in "appaddress" key are found.
 Returns 0, otherwise.
 */
- (NSInteger) setVoipInfoFromPN:(NSString*)info {
    
    KLog(@"setVoipInfoFromPN: %@",info);
    EnLogd(@"setVoipInfoFromPN: %@",info);
    NSInteger retValue = 1;//Success
    
    KLog(@"voipInfo:%@",voipInfo.serverUrl);
    EnLogd(@"voipInfo:%@",voipInfo.serverUrl);
    
    viFromPN = [self parseVoipInfoFromString:info];//- modifies voipInfo object
    if(!viFromPN) {
        KLog(@"No voipInfo in PN. Returns");
        EnLogd(@"No voipInfo in PN. Returns");
        return 0;
    }
    
    KLog(@"viFromPN = %@",viFromPN);
    EnLogd(@"viFromPN = %@",viFromPN);
    
    //- set the current registration info
    self.serverHost = viFromPN.serverUrl;
    self.portTCP = viFromPN.tcpPort;
    self.portUDP = viFromPN.udpPort;
    if(viFromPN.priority)
        self.transport = TRANSPORT_TCP;
    else
        self.transport = TRANSPORT_UDP;
    //
    
    if([viFromPN.serverUrl isEqualToString:voipInfo.serverUrl] &&
       viFromPN.udpPort == voipInfo.udpPort &&
       viFromPN.tcpPort == voipInfo.tcpPort  &&
       [self isRegistered]) {
        
        KLog(@"Reg Not Required.");
        EnLogd(@"Reg Not Required. voipInfo:%@",voipInfo.serverUrl);
        
        self.isRmsIPAddressChanged = NO;
    }
    else {
        KLog(@"Reg Required.");
        EnLogd(@"Reg Required.");
        self.isRmsIPAddressChanged = YES;
    }
    
    return retValue;
}

/*
 info would be of "ip_address:udp:port:tcp:port:tcp|udp"
 Returns result in SettingModelVoip object.
 */
-(SettingModelVoip*)parseVoipInfoFromString:(NSString*)info
{
    KLog(@"info=%@",info);
    EnLogd(@"info=%@",info);
    
    SettingModelVoip* viResult = [[SettingModelVoip alloc]initWithObject:voipInfo];
    
    NSArray* arrValue = [info componentsSeparatedByString:@":"];
    if(arrValue.count>=5) {
        NSString* ipAddress = [arrValue objectAtIndex:0];
        NSString* portKey1 = [arrValue objectAtIndex:1];
        NSString* portVal1 = [arrValue objectAtIndex:2];
        NSString* portKey2 = [arrValue objectAtIndex:3];
        NSString* portVal2 = [arrValue objectAtIndex:4];
        NSString* protoPriority=@"tcp";
        if(arrValue.count>5) {
            protoPriority = [arrValue objectAtIndex:5];
        } else {
            KLog(@"No proto-priority mentioned. Default is tcp.");
            EnLogd(@"No proto-priority mentioned. Default is tcp.");
        }
        
        if(ipAddress.length) {
            viResult.serverUrl = ipAddress;
        } else {
            KLog(@"No IP address found.");
            EnLogd(@"No IP address found.");
            return nil;
        }
        
        if(portKey1.length && portKey2.length && portVal1.length && portVal2.length) {
            if([portKey1 caseInsensitiveCompare:@"udp"]==NSOrderedSame)
                viResult.udpPort = [portVal1 intValue];
            else if([portKey1 caseInsensitiveCompare:@"tcp"]==NSOrderedSame)
                viResult.tcpPort = [portVal1 intValue];
            if([portKey2 caseInsensitiveCompare:@"udp"]==NSOrderedSame)
                viResult.udpPort = [portVal2 intValue];
            if([portKey2 caseInsensitiveCompare:@"tcp"]==NSOrderedSame)
                viResult.tcpPort = [portVal2 intValue];
            
        } else {
            KLog(@"No UDP or TCP key found.");
            EnLogd(@"No UDP or TCP key found.");
            return nil;
        }
        
        if(protoPriority.length) {
            if([protoPriority caseInsensitiveCompare:@"tcp"] == NSOrderedSame)
                viResult.priority = 1;
            else if([protoPriority caseInsensitiveCompare:@"udp"] == NSOrderedSame)
                viResult.priority = 0;
            else {
                KLog(@"Warning: No tcp or udp value found. Default is tcp.");
                EnLogd(@"Warning: No tcp or udp value found. Default is tcp.");
                viResult.priority = 1;
            }
        } else {
            KLog(@"No proto-priority mentioned. Default is tcp.");
            EnLogd(@"No proto-priority mentioned. Default is tcp.");
            viResult.priority = 1;
        }
    }
    else {
        viResult = nil;
        KLog(@"***ERR: Invalid value for \"voip_ip/ipaddress\" key.");
        EnLogd(@"***ERR: Invalid value for \"voip_ip/ipaddress\" key.");
    }
    
    return viResult;
}

- (void)transformLinphoneCoreToKeys {
    
    LinphoneManager *lm = LinphoneManager.instance;
    
    // root section
    {
        const bctbx_list_t *accounts = linphone_core_get_proxy_config_list(LC);
        size_t count = bctbx_list_size(accounts);
        for (size_t i = 1; i <= count; i++, accounts = accounts->next) {
            NSString *key = [NSString stringWithFormat:@"menu_account_%lu", i];
            LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)accounts->data;
            [self setCString:linphone_address_get_username(linphone_proxy_config_get_identity_address(proxy))
                      forKey:key];
        }
        
        [self setBool:linphone_core_video_display_enabled(LC) forKey:@"enable_video_preference"];
        [self setBool:[LinphoneManager.instance lpConfigBoolForKey:@"auto_answer"]
               forKey:@"enable_auto_answer_preference"];
        [self setBool:[lm lpConfigBoolForKey:@"account_mandatory_advanced_preference"]
               forKey:@"account_mandatory_advanced_preference"];
    }
    
    // account section
    { [self transformAccountToKeys:nil]; }
    
    // audio section
    {
        [self transformCodecsToKeys:linphone_core_get_audio_codecs(LC)];
        [self setFloat:linphone_core_get_playback_gain_db(LC) forKey:@"playback_gain_preference"];
        [self setFloat:linphone_core_get_mic_gain_db(LC) forKey:@"microphone_gain_preference"];
        [self setInteger:[lm lpConfigIntForKey:@"codec_bitrate_limit"
                                     inSection:@"audio"
                                   withDefault:kLinphoneAudioVbrCodecDefaultBitrate]
                  forKey:@"audio_codec_bitrate_limit_preference"];
        [self setInteger:[lm lpConfigIntForKey:@"voiceproc_preference" withDefault:1] forKey:@"voiceproc_preference"];
        [self setInteger:[lm lpConfigIntForKey:@"eq_active" inSection:@"sound" withDefault:0] forKey:@"eq_active"];
    }
    
    // call section
    {
        [self setBool:linphone_core_get_use_info_for_dtmf(LC) forKey:@"sipinfo_dtmf_preference"];
        [self setBool:linphone_core_get_use_rfc2833_for_dtmf(LC) forKey:@"rfc_dtmf_preference"];
        
        [self setInteger:linphone_core_get_inc_timeout(LC) forKey:@"incoming_call_timeout_preference"];
        [self setInteger:linphone_core_get_in_call_timeout(LC) forKey:@"in_call_timeout_preference"];
        
        [self setBool:[lm lpConfigBoolForKey:@"repeat_call_notification"]
               forKey:@"repeat_call_notification_preference"];
    }
    
    // network section
    {
        [self setBool:[lm lpConfigBoolForKey:@"edge_opt_preference" withDefault:NO] forKey:@"edge_opt_preference"];
        [self setBool:[lm lpConfigBoolForKey:@"wifi_only_preference" withDefault:NO] forKey:@"wifi_only_preference"];
        [self setCString:linphone_core_get_stun_server(LC) forKey:@"stun_preference"];
        [self setBool:linphone_nat_policy_ice_enabled(linphone_core_get_nat_policy(LC)) forKey:@"ice_preference"];
        [self setBool:linphone_nat_policy_turn_enabled(linphone_core_get_nat_policy(LC)) forKey:@"turn_preference"];
        [self setCString:linphone_nat_policy_get_stun_server_username(linphone_core_get_nat_policy(LC))
                  forKey:@"turn_username"];
        
        int random_port_preference = [lm lpConfigIntForKey:@"random_port_preference" withDefault:1];
        [self setInteger:random_port_preference forKey:@"random_port_preference"];
        int port = [lm lpConfigIntForKey:@"port_preference" withDefault:5060];
        [self setInteger:port forKey:@"port_preference"];
        {
            int minPort, maxPort;
            linphone_core_get_audio_port_range(LC, &minPort, &maxPort);
            if (minPort != maxPort)
                [self setObject:[NSString stringWithFormat:@"%d-%d", minPort, maxPort] forKey:@"audio_port_preference"];
            else
                [self setObject:[NSString stringWithFormat:@"%d", minPort] forKey:@"audio_port_preference"];
        }
        /* CMP
        {
            int minPort, maxPort;
            linphone_core_get_video_port_range(LC, &minPort, &maxPort);
            if (minPort != maxPort)
                [self setObject:[NSString stringWithFormat:@"%d-%d", minPort, maxPort] forKey:@"video_port_preference"];
            else
                [self setObject:[NSString stringWithFormat:@"%d", minPort] forKey:@"video_port_preference"];
        }
        [self setBool:linphone_core_ipv6_enabled(LC) forKey:@"use_ipv6"];
        */
        [self setBool:TRUE forKey:@"use_ipv6"];
        LinphoneMediaEncryption menc = linphone_core_get_media_encryption(LC);
        const char *val;
        switch (menc) {
            case LinphoneMediaEncryptionSRTP:
                val = "SRTP";
                break;
            case LinphoneMediaEncryptionZRTP:
                val = "ZRTP";
                break;
            case LinphoneMediaEncryptionDTLS:
                val = "DTLS";
                break;
            case LinphoneMediaEncryptionNone:
                val = "None";
                break;
        }
        
        //BOOL adaptiveRateControl = linphone_core_adaptive_rate_control_enabled(LC);
        //linphone_call_params_enable_low_bandwidth
        [self setCString:val forKey:@"media_encryption_preference"];
        [self setInteger:linphone_core_get_upload_bandwidth(LC) forKey:@"upload_bandwidth_preference"];
        [self setInteger:linphone_core_get_download_bandwidth(LC) forKey:@"download_bandwidth_preference"];
        [self setBool:linphone_core_adaptive_rate_control_enabled(LC) forKey:@"adaptive_rate_control_preference"];
    }
    
    // tunnel section
    if (linphone_core_tunnel_available()) {
        LinphoneTunnel *tunnel = linphone_core_get_tunnel(LC);
        [self setObject:[lm lpConfigStringForKey:@"tunnel_mode_preference" withDefault:@"off"]
                 forKey:@"tunnel_mode_preference"];
        const MSList *configs = linphone_tunnel_get_servers(tunnel);
        if (configs != NULL) {
            LinphoneTunnelConfig *ltc = (LinphoneTunnelConfig *)configs->data;
            [self setCString:linphone_tunnel_config_get_host(ltc) forKey:@"tunnel_address_preference"];
            [self setInteger:linphone_tunnel_config_get_port(ltc) forKey:@"tunnel_port_preference"];
        } else {
            [self setCString:"" forKey:@"tunnel_address_preference"];
            [self setInteger:443 forKey:@"tunnel_port_preference"];
        }
    }
    
    //advanced section
    //TODO [self setBool:[lm lpConfigBoolForKey:@"use_rls_presence" withDefault:YES] forKey:@"use_rls_presence"];
    
    changedDict = [[NSMutableDictionary alloc] init];
    
    // Post event
    /* TODO: CMP remove notification handle as well
     NSDictionary *eventDic = [NSDictionary dictionaryWithObject:self forKey:@"settings"];
     [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneLogsUpdate object:self userInfo:eventDic];
     */
}

- (BOOL)synchronize {
    
    KLog(@"synchronize");
    
    [self transformLinphoneCoreToKeys];
    
	//@try {

	LinphoneManager *lm = LinphoneManager.instance;
	// root section
	{
		BOOL account_changed = NO;
		for (NSString *key in changedDict) {
			if ([key hasPrefix:@"account_"] && [self valueChangedForKey:key]) {
				account_changed = YES;
				break;
			}
		}
		account_changed |= [self valueChangedForKey:@"port_preference"];
		account_changed |= [self valueChangedForKey:@"random_port_preference"];
		account_changed |= [self valueChangedForKey:@"use_ipv6"];
        
		//if (account_changed)
			[self synchronizeAccounts];
        
		bool enableVideo = [self boolForKey:@"enable_video_preference"];
		linphone_core_enable_video_capture(LC, enableVideo);
		linphone_core_enable_video_display(LC, enableVideo);
        
		bool enableAutoAnswer = [self boolForKey:@"enable_auto_answer_preference"];
		[LinphoneManager.instance lpConfigSetBool:enableAutoAnswer forKey:@"auto_answer"];
	}

	// audio section
	{
		[self synchronizeCodecs:linphone_core_get_audio_codecs(LC)];

		float playback_gain = [self floatForKey:@"playback_gain_preference"];
		linphone_core_set_playback_gain_db(LC, playback_gain);

		float mic_gain = [self floatForKey:@"microphone_gain_preference"];
		linphone_core_set_mic_gain_db(LC, mic_gain);

		[lm lpConfigSetInt:[self integerForKey:@"audio_codec_bitrate_limit_preference"]
					forKey:@"codec_bitrate_limit"
				 inSection:@"audio"];

		BOOL voice_processing = [self boolForKey:@"voiceproc_preference"];
		[lm lpConfigSetInt:voice_processing forKey:@"voiceproc_preference"];

		BOOL equalizer = [self boolForKey:@"eq_active"];
		[lm lpConfigSetBool:equalizer forKey:@"eq_active" inSection:@"sound"];

		[LinphoneManager.instance configureVbrCodecs];

		NSString *au_device = @"AU: Audio Unit Receiver";
		if (!voice_processing) {
			au_device = @"AU: Audio Unit NoVoiceProc";
		}
		linphone_core_set_capture_device(LC, [au_device UTF8String]);
		linphone_core_set_playback_device(LC, [au_device UTF8String]);
    }

    // call section
    {
        /*
        int incallTO1 = [self integerForKey:@"in_call_timeout_preference"];
        int incalTO2 = [self integerForKey:@"incoming_call_timeout_preference"];
        */
        
        linphone_core_set_use_rfc2833_for_dtmf(LC, [self boolForKey:@"rfc_dtmf_preference"]);
        linphone_core_set_use_info_for_dtmf(LC, [self boolForKey:@"sipinfo_dtmf_preference"]);
        linphone_core_set_inc_timeout(LC, [self integerForKey:@"incoming_call_timeout_preference"]);
        linphone_core_set_in_call_timeout(LC, [self integerForKey:@"in_call_timeout_preference"]);
        [lm lpConfigSetString:[self stringForKey:@"voice_mail_uri_preference"] forKey:@"voice_mail_uri"];
        [lm lpConfigSetBool:[self boolForKey:@"repeat_call_notification_preference"]
                     forKey:@"repeat_call_notification"];
    }

    // network section
    {
        BOOL edgeOpt = [self boolForKey:@"edge_opt_preference"];
        [lm lpConfigSetInt:edgeOpt forKey:@"edge_opt_preference"];
        
        BOOL wifiOnly = [self boolForKey:@"wifi_only_preference"];
        [lm lpConfigSetInt:wifiOnly forKey:@"wifi_only_preference"];
        if ([self valueChangedForKey:@"wifi_only_preference"]) {
            [LinphoneManager.instance setupNetworkReachabilityCallback];
        }
        
        LinphoneNatPolicy *LNP = linphone_core_get_nat_policy(LC);
        //CMP NSString *stun_server = [self stringForKey:@"stun_preference"];
        NSString *stun_server = [self stunServer];
        if ([stun_server length] > 0) {
            linphone_core_set_stun_server(LC, [stun_server UTF8String]);
            linphone_nat_policy_set_stun_server(LNP, [stun_server UTF8String]);
            BOOL ice_preference = [self boolForKey:@"ice_preference"];
            linphone_nat_policy_enable_ice(LNP, ice_preference);
            linphone_nat_policy_enable_turn(LNP, [self boolForKey:@"turn_preference"]);
            NSString *turn_username = [self stringForKey:@"turn_username"];
            NSString *turn_password = [self stringForKey:@"turn_password"];
            
            //July 23, 2018
            /*
            if(self.publicIPAddr.length) {
                linphone_core_set_nat_address(LC,self.publicIPAddr.UTF8String);
                linphone_core_set_firewall_policy(LC,LinphonePolicyUseNatAddress);
            }*/
            
            if ([turn_username length] > 0) {
                const LinphoneAuthInfo *turnAuthInfo = nil;
                if ([turn_password length] > 0)
                    turnAuthInfo = linphone_auth_info_new([turn_username UTF8String], NULL,
                                                          [turn_password UTF8String], NULL, NULL, NULL);
                else
                    turnAuthInfo = linphone_core_find_auth_info(LC, NULL, [turn_username UTF8String], NULL);
                if (turnAuthInfo != NULL)
                    linphone_core_add_auth_info(LC, turnAuthInfo);
                linphone_nat_policy_set_stun_server_username(LNP, linphone_auth_info_get_username(turnAuthInfo));
            }
        } else {
            linphone_nat_policy_enable_stun(LNP, FALSE);
            linphone_nat_policy_set_stun_server(LNP, NULL);
            linphone_core_set_stun_server(LC, NULL);
        }
        linphone_core_set_nat_policy(LC, LNP);
        {
            NSString *audio_port_preference = [self stringForKey:@"audio_port_preference"];
            if(audio_port_preference.length) {
                int minPort, maxPort;
                [LinphoneCoreSettingsStore parsePortRange:audio_port_preference minPort:&minPort maxPort:&maxPort];
                linphone_core_set_audio_port_range(LC, minPort, maxPort);
            }
        }
        /*
        {
            NSString *video_port_preference = [self stringForKey:@"video_port_preference"];
            if(video_port_preference.length) {
                int minPort, maxPort;
                [LinphoneCoreSettingsStore parsePortRange:video_port_preference minPort:&minPort maxPort:&maxPort];
                linphone_core_set_video_port_range(LC, minPort, maxPort);
            }
        }*/
        
        NSString *menc = [self stringForKey:@"media_encryption_preference"];
        if (menc && [menc compare:@"SRTP"] == NSOrderedSame)
            linphone_core_set_media_encryption(LC, LinphoneMediaEncryptionSRTP);
        else if (menc && [menc compare:@"ZRTP"] == NSOrderedSame)
            linphone_core_set_media_encryption(LC, LinphoneMediaEncryptionZRTP);
        else if (menc && [menc compare:@"DTLS"] == NSOrderedSame)
            linphone_core_set_media_encryption(LC, LinphoneMediaEncryptionDTLS);
        else
            linphone_core_set_media_encryption(LC, LinphoneMediaEncryptionNone);
        
        linphone_core_enable_adaptive_rate_control(LC, [self boolForKey:@"adaptive_rate_control_preference"]);
    }

    // tunnel section
    {
        if (linphone_core_tunnel_available()) {
            NSString *lTunnelPrefMode = [self stringForKey:@"tunnel_mode_preference"];
            NSString *lTunnelPrefAddress = [self stringForKey:@"tunnel_address_preference"];
            int lTunnelPrefPort = [self integerForKey:@"tunnel_port_preference"];
            LinphoneTunnel *tunnel = linphone_core_get_tunnel(LC);
            LinphoneTunnelMode mode = LinphoneTunnelModeDisable;
            int lTunnelPort = 443;
            if (lTunnelPrefPort) {
                lTunnelPort = lTunnelPrefPort;
            }
            
            linphone_tunnel_clean_servers(tunnel);
            if (lTunnelPrefAddress && [lTunnelPrefAddress length]) {
                LinphoneTunnelConfig *ltc = linphone_tunnel_config_new();
                linphone_tunnel_config_set_host(ltc, [lTunnelPrefAddress UTF8String]);
                linphone_tunnel_config_set_port(ltc, lTunnelPort);
                linphone_tunnel_add_server(tunnel, ltc);
                
                if ([lTunnelPrefMode isEqualToString:@"off"]) {
                    mode = LinphoneTunnelModeDisable;
                } else if ([lTunnelPrefMode isEqualToString:@"on"]) {
                    mode = LinphoneTunnelModeEnable;
                } else if ([lTunnelPrefMode isEqualToString:@"auto"]) {
                    mode = LinphoneTunnelModeAuto;
                } else {
                    LOGE(@"Unexpected tunnel mode [%s]", [lTunnelPrefMode UTF8String]);
                }
            }
            
            [lm lpConfigSetString:lTunnelPrefMode forKey:@"tunnel_mode_preference"];
            linphone_tunnel_set_mode(tunnel, mode);
        }
    }

    // advanced section
    {
        BOOL animations = [self boolForKey:@"animations_preference"];
        [lm lpConfigSetInt:animations forKey:@"animations_preference"];
        
        UIDevice *device = [UIDevice currentDevice];
        bool backgroundSupported =
        [device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported];
        BOOL isbackgroundModeEnabled = backgroundSupported && [self boolForKey:@"backgroundmode_preference"];
        [lm lpConfigSetInt:isbackgroundModeEnabled forKey:@"backgroundmode_preference"];
        
        [lm lpConfigSetInt:[self integerForKey:@"start_at_boot_preference"] forKey:@"start_at_boot_preference"];
        [lm lpConfigSetInt:[self integerForKey:@"autoanswer_notif_preference"]
                    forKey:@"autoanswer_notif_preference"];
        [lm lpConfigSetInt:[self integerForKey:@"show_msg_in_notif"] forKey:@"show_msg_in_notif"];
        
        /* TODO if ([self integerForKey:@"use_rls_presence"])
        {
            
            [self setInteger:0 forKey:@"use_rls_presence"];
            NSString *rls_uri =
            [lm lpConfigStringForKey:@"rls_uri" inSection:@"sip" withDefault:@"sips:rls@54.148.51.116"];
            LinphoneAddress *rls_addr = linphone_address_new(rls_uri.UTF8String);
            const char *rls_domain = linphone_address_get_domain(rls_addr);
            const MSList *proxies = linphone_core_get_proxy_config_list(LC);
            if (!proxies) {
                // Enable it if no proxy config for first launch of app
                [self setInteger:1 forKey:@"use_rls_presence"];
            } else {
                while (proxies) {
                    const char *proxy_domain = linphone_proxy_config_get_domain(proxies->data);
                    if (strcmp(rls_domain, proxy_domain) == 0) {
                        [self setInteger:1 forKey:@"use_rls_presence"];
                        break;
                    }
                    proxies = proxies->next;
                }
            }
            linphone_address_unref(rls_addr);
        }
        //[lm lpConfigSetInt:[self integerForKey:@"use_rls_presence"] forKey:@"use_rls_presence"];
        
        const MSList *lists = linphone_core_get_friends_lists(LC);
        while (lists) {
            linphone_friend_list_enable_subscriptions(lists->data, [self integerForKey:@"use_rls_presence"]);
            lists = lists->next;
        }*/
        
        BOOL firstloginview = [self boolForKey:@"enable_first_login_view_preference"];
        [lm lpConfigSetInt:firstloginview forKey:@"enable_first_login_view_preference"];
        
        NSString *displayname = [self stringForKey:@"primary_displayname_preference"];
        NSString *username = [self stringForKey:@"primary_username_preference"];
        LinphoneAddress *parsed = linphone_core_get_primary_contact_parsed(LC);
        if (parsed != NULL) {
            linphone_address_set_display_name(parsed, [displayname UTF8String]);
            linphone_address_set_username(parsed, [username UTF8String]);
            char *contact = linphone_address_as_string(parsed);
            linphone_core_set_primary_contact(LC, contact);
            ms_free(contact);
            linphone_address_unref(parsed);
            
            //NOV 2017
            /* TODO: prepare a contact URI which will be used in REGISTER request.
             e.g: <sip:public ip address: public port>
             Is it ok to overriding linphone's functionality of assigining primary contact? Check.
             
            if(self.publicIPAddr.length && self.publicPort.length) {
                NSString* primaryContact = [NSString stringWithFormat:@"sip:%@:%@",self.publicIPAddr,self.publicPort];
                if(primaryContact.length) {
                    const char* pContact = [primaryContact UTF8String];
                    if(pContact) {
                        linphone_core_set_primary_contact(LC, pContact);
                    }
                }
            }*/
            //
        }
        
        [lm lpConfigSetInt:[self integerForKey:@"account_mandatory_advanced_preference"]
                    forKey:@"account_mandatory_advanced_preference"];
    }

    changedDict = [[NSMutableDictionary alloc] init];
    
    //DEC 2017
    /*
    LinphoneConfig* lpCfg = linphone_core_get_config(LC);
    int tmp = lp_config_get_int(lpCfg, "net", "dns_srv_enabled", 1);
    KLog(@"dns_srv_enabled:%d",tmp);
    //linphone_core_enable_dns_srv(LC, tmp);
    tmp = lp_config_get_int(lpCfg, "net", "dns_search_enabled", 1);
    KLog(@"dns_search_enabled:%d",tmp);
    //linphone_core_enable_dns_search(, tmp);
    
    int port = lp_config_get_int(lpCfg,"sip","sip_port",5060);
    KLog(@"sip_port = %d",port);
    port = lp_config_get_int(lpCfg,"sip","sip_tcp_port",5060);
    KLog(@"sip_tcp_port = %d",port);
    */
    
    // Post event
    /*
    NSDictionary *eventDic = [NSDictionary dictionaryWithObject:self forKey:@"settings"];
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneSettingsUpdate object:self userInfo:eventDic];
    */
    return YES;
    //} @catch (NSException *e) {
    //	// may happen when application is terminated, since we are destroying the core
    //	LOGI(@"Core probably already destroyed, cannot synchronize settings. Skipping. %@", [e callStackSymbols]);
    //}
    // return NO;
}

-(void)unRegister {
    
    KLog(@"unRegister");
    EnLogd(@"unRegister");
    
    LinphoneProxyConfig* proxyConf = linphone_core_get_default_proxy_config(LC);
    /*
    LinphoneProxyConfig* proxyCfg = bctbx_list_nth_data(linphone_core_get_proxy_config_list(LC),
                                                        [self integerForKey:@"current_proxy_config_preference"]);
     */
    if(nil != proxyConf) {
        linphone_proxy_config_enable_register(proxyConf, false);
        //DEC 2017 linphone_proxy_config_enable_avpf(proxyConf, false);
        linphone_proxy_config_set_avpf_mode(proxyConf,LinphoneAVPFDefault);
        linphone_proxy_config_set_expires(proxyConf, 0);//0=unregister
        linphone_proxy_config_done(proxyConf);
        KLog(@"unRegister done");
        EnLogd(@"unRegister done");
    } else {
        KLog(@"***ERR. Proxy conf not found");
        EnLogd(@"***ERR. Proxy conf not found");
    }
    [[Setting sharedSetting]setDeviceInfoWithVoipToken:@""];
}

//- Just do the opposite to what the unRegister method does
-(void)reEnable {
    KLog(@"reEnable");
    EnLogd(@"reEnable");
    
    LinphoneProxyConfig* proxyConf = linphone_core_get_default_proxy_config(LC);
    if(nil != proxyConf) {
        linphone_proxy_config_enable_register(proxyConf, true);
        //DEC 2017 linphone_proxy_config_enable_avpf(proxyConf, true);
        linphone_proxy_config_set_avpf_mode(proxyConf, LinphoneAVPFEnabled);
        linphone_proxy_config_set_expires(proxyConf, kRegistrationExpiryTime);
        linphone_proxy_config_done(proxyConf);
        
        LinphoneManager* instance = LinphoneManager.instance;
        LinphoneManager.instance.connectivity = none;
        [instance becomeActive];
        
        KLog(@"reEnable done");
        EnLogd(@"reEnable done");
    } else {
        KLog(@"***ERR. Proxy conf not found");
        EnLogd(@"***ERR. Proxy conf not found");
    }
    [[Setting sharedSetting]setDeviceInfoWithVoipToken:@""];
}

/*
- (BOOL)isRegistrationRequired {
    
    if([viFromPN.serverUrl isEqualToString:voipInfo.serverUrl]) {
        KLog(@"Reg Not Required.");
        return NO;
    }
    else {
        KLog(@"Reg Required.");
        return YES;
    }
}*/

- (void)refreshRegister:(BOOL)isTransportChanged {
    
    KLog(@"refreshRegister");
    EnLogd(@"refreshRegister");
    if([Common isNetworkAvailable] != NETWORK_AVAILABLE) {
        KLog(@"No network. Returns.");
        EnLogd(@"No network. Returns.");
        return;
    }
    
    if([self isRegistered] && !isTransportChanged && !self.isRmsIPAddressChanged) {
        KLog(@"Already registered. returns.");
        EnLogd(@"Already registered. returns.");
        return;
    }
    
    if(self.regAttempt>kMaxRegsitrationRetry) {
        KLog(@"Reg. attempted: %ld",self.regAttempt);
        return;
    }
    
    KLog(@"Registration attempt: %ld", self.regAttempt);
    EnLogd(@"Registration attempt: %ld", self.regAttempt);
    
    int port = self.portTCP;
    if([self.transport isEqualToString:TRANSPORT_UDP])
        port = self.portUDP;
    
    KLog(@"Registration using %@:%d",self.transport,port);
    EnLogd(@"Registration using %@:%d",self.transport,port);
    
    /*FEB 2018, TODO
    if(isTransportChanged) {
        KLog(@"Synchronize account");
        EnLogd(@"Synchronize account");
        LinphoneManager.instance.connectivity = none;//TODO
        [self synchronize];
    }
    LinphoneManager.instance.connectivity = none;
    */
    
    [self synchronize];
    self.registrationStatus = LinphoneRegistrationNone;
    [LinphoneManager.instance becomeActive];
}

-(void)checkRegistrationStatus {
    
    KLog(@"checkRegistrationStatus");
    EnLogd(@"checkRegistrationStatus");
       
    if(LinphoneRegistrationOk != self.registrationStatus) {
        
        if(LinphoneRegistrationFailed == self.registrationStatus) {
            self.regAttempt++;
            //KLog(@"regAttempt = %ld",self.regAttempt);
            if(self.regAttempt%2 == 0) // TODO if(1)
            {
                KLog(@"proto change");
                
                if([self.transport isEqualToString:TRANSPORT_UDP]) {
                    KLog(@"Changing transport from UDP to TCP");
                    EnLogd(@"Changing transport from UDP to TCP");
                    self.transport = TRANSPORT_TCP;
                }
                else {
                    KLog(@"Changing transport from TCP to UDP");
                    EnLogd(@"Changing transport from TCP to UDP");
                    self.transport = TRANSPORT_UDP;
                }
                [self refreshRegister:YES];
            } else {
                KLog(@"No proto change");
                [self refreshRegister:NO];
            }
        }
    }
    else {
        KLog(@"Registration Done with %@:%@",self.serverHost, self.transport);
        EnLogd(@"Registration Done with %@:%@",self.serverHost, self.transport);
    }
}

#pragma mark -
#pragma mark Registration Update

- (void)registrationUpdateEvent:(NSNotification *)notif {
    
    LinphoneProxyConfig *config = linphone_core_get_default_proxy_config(LC);
    [self proxyConfigUpdate:config];
}

-(BOOL)isRegistered {
    
    BOOL ret = NO;
    LinphoneRegistrationState state = LinphoneRegistrationNone;
    LinphoneProxyConfig *config = linphone_core_get_default_proxy_config(LC);
    
    /*
    LinphoneGlobalState gstate = linphone_core_get_global_state(LC);
     
    if (![[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn]) {
        //message = NSLocalizedString(@"Acoount not logged-in", nil);
    } else if (gstate == LinphoneGlobalOn && !linphone_core_is_network_reachable(LC)) {
        //message = NSLocalizedString(@"Network down", nil);
    } else if (config == NULL) {
        state = LinphoneRegistrationNone;
        if (linphone_core_get_proxy_config_list(LC) != NULL) {
            //message = NSLocalizedString(@"No default account", nil);
        } else {
            //message = NSLocalizedString(@"No account configured", nil);
        }
    }else */
    {
        if(config != NULL) {
            state = linphone_proxy_config_get_state(config);
            if(LinphoneRegistrationOk == state)
                ret = YES;
        }
    }
    
    return ret;
}

- (void)proxyConfigUpdate:(LinphoneProxyConfig *)config {
    
    LinphoneRegistrationState state = LinphoneRegistrationNone;
    NSString *message = nil;
    LinphoneGlobalState gstate = linphone_core_get_global_state(LC);
    
    if (![[ConfigurationReader sharedConfgReaderObj]getIsLoggedIn]) {
        message = NSLocalizedString(@"Acoount not logged-in", nil);
    } else if (gstate == LinphoneGlobalOn && !linphone_core_is_network_reachable(LC)) {
        message = NSLocalizedString(@"Network down", nil);
    } else if (config == NULL) {
        state = LinphoneRegistrationNone;
        if (linphone_core_get_proxy_config_list(LC) != NULL) {
            message = NSLocalizedString(@"No default account", nil);
        } else {
            message = NSLocalizedString(@"No account configured", nil);
        }
    } else {
        state = linphone_proxy_config_get_state(config);
        
        switch (state) {
            case LinphoneRegistrationOk:
                self.registrationStatus = LinphoneRegistrationOk;
                message = NSLocalizedString(@"Registered", nil);
                KLog(@"Reg. state=%d, %@",state, message);
                EnLogd(@"Reg. state=%d, %@",state, message);
                [self checkRegistrationStatus];
                break;
                
            case LinphoneRegistrationNone:
                self.registrationStatus = LinphoneRegistrationNone;
                message = NSLocalizedString(@"Not registered", nil);
                KLog(@"Reg. state=%d, %@",state, message);
                EnLogd(@"Reg. state=%d, %@",state, message);
                break;
                
            case LinphoneRegistrationCleared:
                self.registrationStatus = LinphoneRegistrationCleared;
                message = NSLocalizedString(@"Not registered", nil);
                KLog(@"Reg. state=%d, %@",state, message);
                EnLogd(@"Reg. state=%d, %@",state, message);
                break;
                
            case LinphoneRegistrationFailed:
            {
                self.registrationStatus = LinphoneRegistrationFailed;
                message = NSLocalizedString(@"Registration failed", nil);
                KLog(@"Reg. state=%d, %@",state, message);
                EnLogd(@"Reg. state=%d, %@",state, message);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self checkRegistrationStatus];
                });
            }
                break;
                
            case LinphoneRegistrationProgress:
                self.registrationStatus = LinphoneRegistrationProgress;
                message = NSLocalizedString(@"Registration in progress", nil);
                KLog(@"Reg. state=%d, %@",state, message);
                EnLogd(@"Reg. state=%d, %@",state, message);
                break;
                
            default:
                KLog(@"Unknown Reg. state=%d, %@",state, message);
                EnLogd(@"Unknown Reg. state=%d, %@",state, message);
                break;
        }
    }
    
    /*
    KLog(@"proxyConfigUpdate:state=%d, %@",state, message);
    EnLogd(@"proxyConfigUpdate:state=%d, %@",state, message);
    */
}

+(NSString*)getCallStateString:(LinphoneCallState)state {
    
    NSString* sState = @"";
    
    switch(state) {
        case LinphoneCallIdle: /**< Initial call state */
            sState = @"Idle";
            break;
        case LinphoneCallIncomingReceived: /**< This is a new incoming call */
            sState = @"A new incoming call is received.";
            break;
            
        case LinphoneCallOutgoingInit: /**< An outgoing call is started */
            sState = @"An outgoing call is started.";
            break;
            
        case LinphoneCallOutgoingProgress: /**< An outgoing call is in progress */
            sState = @"An outgoing call is in progress.";
            break;
            
        case LinphoneCallOutgoingRinging: /**< An outgoing call is ringing at remote end */
            sState = @"An outgoing call is ringing at remote end.";
            break;
            
        case LinphoneCallOutgoingEarlyMedia: /**< An outgoing call is proposed early media */
            sState = @"An outgoing call is proposed early media.";
            break;
            
        case LinphoneCallConnected: /**< Connected, the call is answered */
            sState = @"Connected, the call is answered.";
            break;
            
        case LinphoneCallStreamsRunning: /**< The media streams are established and running */
            sState = @"The media streams are established and running.";
            break;
            
        case LinphoneCallPausing: /**< The call is pausing at the initiative of local end */
            sState = @"The call is pausing at the initiative of local end.";
            break;
            
        case LinphoneCallPaused: /**< The call is paused, remote end has accepted the pause */
            sState = @"The call is paused, remote end has accepted the pause.";
            break;
            
        case LinphoneCallResuming: /**< The call is being resumed by local end */
            sState = @"The call is being resumed by local end.";
            break;
            
        case LinphoneCallRefered: /**< The call is being transfered to another party, resulting in a new outgoing call to follow immediately */
            sState  = @"The call is being transfered to another party, resulting in a new outgoing call to follow immediately.";
            break;
            
        case LinphoneCallError: /**< The call encountered an error */
            sState = @"The call encountered an error.";
            break;
            
        case LinphoneCallEnd: /**< The call ended normally */
            sState = @"The call ended normally.";
            break;
            
        case LinphoneCallPausedByRemote: /**< The call is paused by remote end */
            sState = @"The call is paused by remote end.";
            break;
            
        case LinphoneCallUpdatedByRemote: /**<The call's parameters change is requested by remote end, used for example when video is added by remote */
            sState = @"The call\'s parameters change is requested by remote end, used for example when video is added by remote.";
            break;
            
        case LinphoneCallIncomingEarlyMedia: /**< We are proposing early media to an incoming call */
            sState = @"We are proposing early media to an incoming call.";
            break;
            
        case LinphoneCallUpdating: /**< A call update has been initiated by us */
            sState = @"A call update has been initiated by us.";
            break;
            
        case LinphoneCallReleased: /**< The call object is no more retained by the core */
            sState = @"The call object is no more retained by the core.";
            break;
            
        case LinphoneCallEarlyUpdatedByRemote: /**< The call is updated by remote while not yet answered (early dialog SIP UPDATE received) */
            sState = @"The call is updated by remote while not yet answered (early dialog SIP UPDATE received).";
            break;
            
        case LinphoneCallEarlyUpdating: /**< We are updating the call while not yet answered (early dialog SIP UPDATE sent) */
            sState = @"We are updating the call while not yet answered (early dialog SIP UPDATE sent).";
            break;
            
        default: {
            sState = @"Unknown";
            break;
        }
    }
    return sState;
}
@end