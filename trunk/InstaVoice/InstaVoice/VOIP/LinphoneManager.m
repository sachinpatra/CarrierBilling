
/* LinphoneManager.h
 *
 * Modified by Pandian for InstaVoice client, June, 2017.
 *
 * Copyright (C) 2011  Belledonne Comunications, Grenoble, France
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

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/sysctl.h>

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "LinphoneCoreSettingsStore.h"
#import "LinphoneManager.h"
//CMP #import "Utils/AudioHelper.h"
//CMP #import "Utils/FileTransferDelegate.h"
#import "AudioHelper.h"

#include "linphone/linphonecore_utils.h"
#include "linphone/lpconfig.h"
#include "mediastreamer2/mscommon.h"

//CMP #import "LinphoneIOSVersion.h"
#import "ConfigurationReader.h"

#import "Contacts.h"
#import "ContactData.h"
#import "ContactDetailData.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"

//#import <AVFoundation/AVAudioPlayer.h>
/* CMP
#import "Utils.h"
#import "PhoneMainView.h"
#import "ChatsListView.h"
#import "ChatConversationView.h"
*/
#import "Log.h"
#import "Logger.h"
#import "Macro.h"
#import <UserNotifications/UserNotifications.h>
#import "Setting.h"
#import "UIType.h"
#import "UIStateMachine.h"
#import "BaseConversationScreen.h"
#import "Common.h"

#import "IVFileLocator.h"
#import "GZIP.h"
#import "ReachMe-Swift.h"
#import "CustomCallViewController.h"
#import "Profile.h"

#define LINPHONE_LOGS_MAX_ENTRY 5000

#define kCallStatsUpdateInterval       5   //in seconds
#define kAllowedOverAllCallQauality    4.1

static LinphoneCore *theLinphoneCore = nil;
static LinphoneManager *theLinphoneManager = nil;

NSString *const LINPHONERC_APPLICATION_KEY = @"app";

NSString *const kLinphoneCoreUpdate = @"LinphoneCoreUpdate";
NSString *const kLinphoneDisplayStatusUpdate = @"LinphoneDisplayStatusUpdate";
NSString *const kLinphoneMessageReceived = @"LinphoneMessageReceived";
NSString *const kLinphoneTextComposeEvent = @"LinphoneTextComposeStarted";
NSString *const kLinphoneCallUpdate = @"LinphoneCallUpdate";
NSString *const kLinphoneRegistrationUpdate = @"LinphoneRegistrationUpdate";
NSString *const kLinphoneAddressBookUpdate = @"LinphoneAddressBookUpdate";
NSString *const kLinphoneMainViewChange = @"LinphoneMainViewChange";
NSString *const kLinphoneLogsUpdate = @"LinphoneLogsUpdate";
NSString *const kLinphoneSettingsUpdate = @"LinphoneSettingsUpdate";
NSString *const kLinphoneBluetoothAvailabilityUpdate = @"LinphoneBluetoothAvailabilityUpdate";
NSString *const kLinphoneConfiguringStateUpdate = @"LinphoneConfiguringStateUpdate";
NSString *const kLinphoneGlobalStateUpdate = @"LinphoneGlobalStateUpdate";
NSString *const kLinphoneNotifyReceived = @"LinphoneNotifyReceived";
NSString *const kLinphoneNotifyPresenceReceivedForUriOrTel = @"LinphoneNotifyPresenceReceivedForUriOrTel";
NSString *const kLinphoneCallEncryptionChanged = @"LinphoneCallEncryptionChanged";
NSString *const kLinphoneFileTransferSendUpdate = @"LinphoneFileTransferSendUpdate";
NSString *const kLinphoneFileTransferRecvUpdate = @"LinphoneFileTransferRecvUpdate";
NSString *const kLinphoneNetworkReachable = @"LinphoneNetworkReachable";


NSString* const kErrCountry = @"country not allowed";
NSString* const kErrLowBalance = @"Low Balance";
NSString* const kErrServiceNotAvail = @"Service Unavailable";
NSString* const kErrNoDestination = @"No destination";

NSString* const kObdWarning = @"Call is not allowed for this country.";
NSString* const kLowBalanceTitle = @"Low Balance";
NSString* const kLowBalance = @"ReachMe Wallet doesn't have sufficient balance to make outgoing calls. Please add money to the wallet or buy an unlimited calling bundle to make this call.";
NSString* const kLowBalanceWarning = @"LowBalanceWarning";
NSString* const kInvalidPhoneNumber = @"Enter a valid phone number.";
NSString* const kEnterCountryCode = @"Enter a phone number with country code.";

const int kLinphoneAudioVbrCodecDefaultBitrate = 36; /*you can override this from linphonerc or linphonerc-factory*/

extern void libmsamr_init(MSFactory *factory);
extern void libmsx264_init(MSFactory *factory);
extern void libmsopenh264_init(MSFactory *factory);
extern void libmssilk_init(MSFactory *factory);
extern void libmswebrtc_init(MSFactory *factory);

#define FRONT_CAM_NAME                                                                                                 \
	"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:1" /*"AV Capture: Front Camera"*/
#define BACK_CAM_NAME                                                                                                  \
	"AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:0" /*"AV Capture: Back Camera"*/

NSString *const kLinphoneOldChatDBFilename = @"chat_database.sqlite";
NSString *const kLinphoneInternalChatDBFilename = @"linphone_chats.db";

#define kCustomHdrOBD @"obd"

@implementation LinphoneCallAppData
- (id)init {
	if ((self = [super init])) {
		batteryWarningShown = FALSE;
		notification = nil;
		videoRequested = FALSE;
		userInfos = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@end

@interface LinphoneManager ()
@property(strong, nonatomic) AVAudioPlayer *messagePlayer;
@end

@implementation LinphoneManager

@synthesize connectivity;

struct codec_name_pref_table {
	const char *name;
	int rate;
	const char *prefname;
};

struct codec_name_pref_table codec_pref_table[] = {{"speex", 8000, "speex_8k_preference"},
												   {"speex", 16000, "speex_16k_preference"},
												   {"silk", 24000, "silk_24k_preference"},
												   {"silk", 16000, "silk_16k_preference"},
												   {"amr", 8000, "amr_preference"},
												   {"gsm", 8000, "gsm_preference"},
												   {"ilbc", 8000, "ilbc_preference"},
												   {"isac", 16000, "isac_preference"},
												   {"pcmu", 8000, "pcmu_preference"},
												   {"pcma", 8000, "pcma_preference"},
												   {"g722", 8000, "g722_preference"},
												   {"g729", 8000, "g729_preference"},
												   {"mp4v-es", 90000, "mp4v-es_preference"},
												   {"h264", 90000, "h264_preference"},
												   {"vp8", 90000, "vp8_preference"},
												   {"mpeg4-generic", 16000, "aaceld_16k_preference"},
												   {"mpeg4-generic", 22050, "aaceld_22k_preference"},
												   {"mpeg4-generic", 32000, "aaceld_32k_preference"},
												   {"mpeg4-generic", 44100, "aaceld_44k_preference"},
												   {"mpeg4-generic", 48000, "aaceld_48k_preference"},
												   {"opus", 48000, "opus_preference"},
												   {"BV16", 8000, "bv16_preference"},
												   {NULL, 0, Nil}};

+ (NSString *)getPreferenceForCodec:(const char *)name withRate:(int)rate {
	int i;
	for (i = 0; codec_pref_table[i].name != NULL; ++i) {
		if (strcasecmp(codec_pref_table[i].name, name) == 0 && codec_pref_table[i].rate == rate)
			return [NSString stringWithUTF8String:codec_pref_table[i].prefname];
	}
	return Nil;
}

+ (NSSet *)unsupportedCodecs {
	NSMutableSet *set = [NSMutableSet set];
	for (int i = 0; codec_pref_table[i].name != NULL; ++i) {
		PayloadType *available = linphone_core_find_payload_type(
			theLinphoneCore, codec_pref_table[i].name, codec_pref_table[i].rate, LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS);
		if ((available == NULL)
			// these two codecs should not be hidden, even if not supported
			&& strcmp(codec_pref_table[i].prefname, "h264_preference") != 0 &&
			strcmp(codec_pref_table[i].prefname, "mp4v-es_preference") != 0) {
			[set addObject:[NSString stringWithUTF8String:codec_pref_table[i].prefname]];
		}
	}
	return set;
}

+ (BOOL)isCodecSupported:(const char *)codecName {
	return (codecName != NULL) &&
		   (NULL != linphone_core_find_payload_type(theLinphoneCore, codecName, LINPHONE_FIND_PAYLOAD_IGNORE_RATE,
													LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS));
}

+ (BOOL)runningOnIpad {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isRunningTests {
	NSDictionary *environment = [[NSProcessInfo processInfo] environment];
	NSString *injectBundle = environment[@"XCInjectBundle"];
	return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

+ (BOOL)isNotIphone3G {
	static BOOL done = FALSE;
	static BOOL result;
	if (!done) {
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		NSString *platform = [[NSString alloc] initWithUTF8String:machine];
		free(machine);

		result = ![platform isEqualToString:@"iPhone1,2"];

		done = TRUE;
	}
	return result;
}

+ (NSString *)getUserAgent {
	return
		[NSString stringWithFormat:@"LinphoneIphone/%@ (Linphone/%s; Apple %@/%@)",
								   [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey],
								   linphone_core_get_version(), [UIDevice currentDevice].systemName,
								   [UIDevice currentDevice].systemVersion];
}

+ (LinphoneManager *)instance {
	@synchronized(self) {
		if (theLinphoneManager == nil) {
            KLog1(@"Create LinphoneManager");
			theLinphoneManager = [[LinphoneManager alloc] init];
		}
	}
	return theLinphoneManager;
}

#ifdef DEBUG
+ (void)instanceRelease {
	if (theLinphoneManager != nil) {
		theLinphoneManager = nil;
	}
}
#endif

+ (BOOL)langageDirectionIsRTL {
	static NSLocaleLanguageDirection dir = NSLocaleLanguageDirectionLeftToRight;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	  dir = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
	});
	return dir == NSLocaleLanguageDirectionRightToLeft;
}

#pragma mark - Lifecycle Functions

- (id)init {
	if ((self = [super init])) {
		[NSNotificationCenter.defaultCenter addObserver:self
											   selector:@selector(audioRouteChangeListenerCallback:)
												   name:AVAudioSessionRouteChangeNotification
												 object:nil];

		NSString *path = [[NSBundle mainBundle] pathForResource:@"msg" ofType:@"wav"];
		self.messagePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];

		_sounds.vibrate = kSystemSoundID_Vibrate;

		_logs = [[NSMutableArray alloc] init];
		_pushDict = [[NSMutableDictionary alloc] init];
		_database = NULL;
		_speakerEnabled = FALSE;
		_bluetoothEnabled = FALSE;
		_conf = FALSE;
		//CMP _fileTransferDelegates = [[NSMutableArray alloc] init];

		pushCallIDs = [[NSMutableArray alloc] init];
        calledNumber = [[NSMutableArray alloc] init];
		//_photoLibrary = [[ALAssetsLibrary alloc] init];
		_isTesting = [LinphoneManager isRunningTests];
        userAgentString = @"";
        
#ifdef REACHME_APP
        bitRate = 0;
        clockRate = 0;
        codec = @"";
        callStatsTimer = nil;
        bwUsage = @"";
        self.showUserRating = YES;
        clMgr = [[CallLogMgr alloc]init];
#endif
        
		//CMP [self renameDefaultSettings];
		[self copyDefaultSettings];
		[self overrideDefaultSettings];

		// set default values for first boot
		if ([self lpConfigStringForKey:@"debugenable_preference"] == nil) {
#ifdef DEBUG
			[self lpConfigSetInt:1 forKey:@"debugenable_preference"];
#else
			[self lpConfigSetInt:0 forKey:@"debugenable_preference"];
#endif
		}

		// by default if handle_content_encoding is not set, we use plain text for debug purposes only
		if ([self lpConfigStringForKey:@"handle_content_encoding" inSection:@"misc"] == nil) {
#ifdef DEBUG
			[self lpConfigSetString:@"none" forKey:@"handle_content_encoding" inSection:@"misc"];
#else
			[self lpConfigSetString:@"conflate" forKey:@"handle_content_encoding" inSection:@"misc"];
#endif
		}

		[self migrateFromUserPrefs];
	}
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma deploymate push "ignored-api-availability"
- (void)silentPushFailed:(NSTimer *)timer {
	if (_silentPushCompletion) {
		LOGI(@"silentPush failed, silentPushCompletion block: %p", _silentPushCompletion);
		_silentPushCompletion(UIBackgroundFetchResultNoData);
		_silentPushCompletion = nil;
	}
}
#pragma deploymate pop

#pragma mark - Migration

- (void)migrationAllPost {
    
	//CMP [self migrationLinphoneSettings];
	//CMP [self migratePushNotificationPerAccount];
}

- (void)migrationAllPre {
	// migrate xmlrpc URL if needed
	if ([self lpConfigBoolForKey:@"migration_xmlrpc"] == NO) {
		[self lpConfigSetString:@"https://subscribe.linphone.org:444/wizard.php"
						 forKey:@"xmlrpc_url"
					  inSection:@"assistant"];
		[self lpConfigSetString:@"sip:rls@sip.linphone.org" forKey:@"rls_uri" inSection:@"sip"];
		[self lpConfigSetBool:YES forKey:@"migration_xmlrpc"];
	}
	[self lpConfigSetBool:NO forKey:@"store_friends" inSection:@"misc"]; //so far, storing friends in files is not needed. may change in the future.
}

static int check_should_migrate_images(void *data, int argc, char **argv, char **cnames) {
	*((BOOL *)data) = TRUE;
	return 0;
}

- (BOOL)migrateChatDBIfNeeded:(LinphoneCore *)lc {
    
	sqlite3 *newDb;
	char *errMsg;
	NSError *error;
	NSString *oldDbPath = [LinphoneManager documentFile:kLinphoneOldChatDBFilename];
	NSString *newDbPath = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
	BOOL shouldMigrate = [[NSFileManager defaultManager] fileExistsAtPath:oldDbPath];
	BOOL shouldMigrateImages = FALSE;
	const char *identity = NULL;
	BOOL migrated = FALSE;
	char *attach_stmt = NULL;
	LinphoneProxyConfig *default_proxy = linphone_core_get_default_proxy_config(lc);

	if (sqlite3_open([newDbPath UTF8String], &newDb) != SQLITE_OK) {
		LOGE(@"Can't open \"%@\" sqlite3 database.", newDbPath);
		return FALSE;
	}

	const char *check_appdata =
		"SELECT url,message FROM history WHERE url LIKE 'assets-library%' OR message LIKE 'assets-library%' LIMIT 1;";
	// will set "needToMigrateImages to TRUE if a result comes by
	sqlite3_exec(newDb, check_appdata, check_should_migrate_images, &shouldMigrateImages, NULL);
	if (!shouldMigrate && !shouldMigrateImages) {
		sqlite3_close(newDb);
		return FALSE;
	}

	LOGI(@"Starting migration procedure");

	if (shouldMigrate) {

		// attach old database to the new one:
		attach_stmt = sqlite3_mprintf("ATTACH DATABASE %Q AS oldchats", [oldDbPath UTF8String]);
		if (sqlite3_exec(newDb, attach_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
			LOGE(@"Can't attach old chat table, error[%s] ", errMsg);
			sqlite3_free(errMsg);
			goto exit_dbmigration;
		}

		// migrate old chats to the new db. The iOS stores timestamp in UTC already, so we can directly put it in the
		// 'utc' field and set 'time' to -1
		const char *migration_statement =
			"INSERT INTO history (localContact,remoteContact,direction,message,utc,read,status,time) "
			"SELECT localContact,remoteContact,direction,message,time,read,state,'-1' FROM oldchats.chat";

		if (sqlite3_exec(newDb, migration_statement, NULL, NULL, &errMsg) != SQLITE_OK) {
			LOGE(@"DB migration failed, error[%s] ", errMsg);
			sqlite3_free(errMsg);
			goto exit_dbmigration;
		}

		// invert direction of old messages, because iOS was storing the direction flag incorrectly
		const char *invert_direction = "UPDATE history SET direction = NOT direction";
		if (sqlite3_exec(newDb, invert_direction, NULL, NULL, &errMsg) != SQLITE_OK) {
			LOGE(@"Inverting direction failed, error[%s]", errMsg);
			sqlite3_free(errMsg);
			goto exit_dbmigration;
		}

		// replace empty from: or to: by the current identity.
		if (default_proxy) {
			identity = linphone_proxy_config_get_identity(default_proxy);
		}
		if (!identity) {
			identity = "sip:unknown@sip.linphone.org";
		}

		char *from_conversion =
			sqlite3_mprintf("UPDATE history SET localContact = %Q WHERE localContact = ''", identity);
		if (sqlite3_exec(newDb, from_conversion, NULL, NULL, &errMsg) != SQLITE_OK) {
			LOGE(@"FROM conversion failed, error[%s] ", errMsg);
			sqlite3_free(errMsg);
		}
		sqlite3_free(from_conversion);

		char *to_conversion =
			sqlite3_mprintf("UPDATE history SET remoteContact = %Q WHERE remoteContact = ''", identity);
		if (sqlite3_exec(newDb, to_conversion, NULL, NULL, &errMsg) != SQLITE_OK) {
			LOGE(@"DB migration failed, error[%s] ", errMsg);
			sqlite3_free(errMsg);
		}
		sqlite3_free(to_conversion);
	}

	// local image paths were stored in the 'message' field historically. They were
	// very temporarily stored in the 'url' field, and now we migrated them to a JSON-
	// encoded field. These are the migration steps to migrate them.

	// move already stored images from the messages to the appdata JSON field
	const char *assetslib_migration = "UPDATE history SET appdata='{\"localimage\":\"'||message||'\"}' , message='' "
									  "WHERE message LIKE 'assets-library%'";
	if (sqlite3_exec(newDb, assetslib_migration, NULL, NULL, &errMsg) != SQLITE_OK) {
		LOGE(@"Assets-history migration for MESSAGE failed, error[%s] ", errMsg);
		sqlite3_free(errMsg);
	}

	// move already stored images from the url to the appdata JSON field
	const char *assetslib_migration_fromurl =
		"UPDATE history SET appdata='{\"localimage\":\"'||url||'\"}' , url='' WHERE url LIKE 'assets-library%'";
	if (sqlite3_exec(newDb, assetslib_migration_fromurl, NULL, NULL, &errMsg) != SQLITE_OK) {
		LOGE(@"Assets-history migration for URL failed, error[%s] ", errMsg);
		sqlite3_free(errMsg);
	}

	// We will lose received messages with remote url, they will be displayed in plain. We can't do much for them..
	migrated = TRUE;

exit_dbmigration:

	if (attach_stmt)
		sqlite3_free(attach_stmt);

	sqlite3_close(newDb);

	// in any case, we should remove the old chat db
	if (shouldMigrate && ![[NSFileManager defaultManager] removeItemAtPath:oldDbPath error:&error]) {
		LOGE(@"Could not remove old chat DB: %@", error);
	}

	LOGI(@"Message storage migration finished: success = %@", migrated ? @"TRUE" : @"FALSE");
	return migrated;
}

- (void)migrateFromUserPrefs {
	static NSString *migration_flag = @"userpref_migration_done";

	if (_configDb == nil)
		return;

	if ([self lpConfigIntForKey:migration_flag withDefault:0]) {
		return;
	}

	NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSArray *defaults_keys = [defaults allKeys];
	NSDictionary *values =
		@{ @"backgroundmode_preference" : @YES,
		   @"debugenable_preference" : @NO,
		   @"start_at_boot_preference" : @YES };
	BOOL shouldSync = FALSE;

	LOGI(@"%lu user prefs", (unsigned long)[defaults_keys count]);

	for (NSString *userpref in values) {
		if ([defaults_keys containsObject:userpref]) {
			LOGI(@"Migrating %@ from user preferences: %d", userpref, [[defaults objectForKey:userpref] boolValue]);
			[self lpConfigSetBool:[[defaults objectForKey:userpref] boolValue] forKey:userpref];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:userpref];
			shouldSync = TRUE;
		} else if ([self lpConfigStringForKey:userpref] == nil) {
			// no default value found in our linphonerc, we need to add them
			[self lpConfigSetBool:[[values objectForKey:userpref] boolValue] forKey:userpref];
		}
	}

	if (shouldSync) {
		LOGI(@"Synchronizing...");
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	// don't get back here in the future
	[self lpConfigSetBool:YES forKey:migration_flag];
}

- (void)migrationLinphoneSettings {
	// we need to proceed to the migration *after* the chat database was opened, so that we know it is in consistent
	// state
	NSString *chatDBFileName = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
	if ([self migrateChatDBIfNeeded:theLinphoneCore]) {
		// if a migration was performed, we should reinitialize the chat database
		linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
	}

	/* AVPF migration */
	if ([self lpConfigBoolForKey:@"avpf_migration_done"] == FALSE) {
		const MSList *proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
		while (proxies) {
			LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)proxies->data;
			const char *addr = linphone_proxy_config_get_addr(proxy);
			// we want to enable AVPF for the proxies
			if (addr &&
				strstr(addr, [LinphoneManager.instance lpConfigStringForKey:@"domain_name"
																  inSection:@"app"
																withDefault:@"sip.linphone.org"]
								 .UTF8String) != 0) {
				LOGI(@"Migrating proxy config to use AVPF");
				linphone_proxy_config_enable_avpf(proxy, TRUE);
			}
			proxies = proxies->next;
		}
		[self lpConfigSetBool:TRUE forKey:@"avpf_migration_done"];
	}
	/* Quality Reporting migration */
	if ([self lpConfigBoolForKey:@"quality_report_migration_done"] == FALSE) {
		const MSList *proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
		while (proxies) {
			LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)proxies->data;
			const char *addr = linphone_proxy_config_get_addr(proxy);
			// we want to enable quality reporting for the proxies that are on linphone.org
			if (addr &&
				strstr(addr, [LinphoneManager.instance lpConfigStringForKey:@"domain_name"
																  inSection:@"app"
																withDefault:@"sip.linphone.org"]
								 .UTF8String) != 0) {
				LOGI(@"Migrating proxy config to send quality report");
				linphone_proxy_config_set_quality_reporting_collector(proxy, "sip:voip-metrics@sip.linphone.org;transport=tls");
				linphone_proxy_config_set_quality_reporting_interval(proxy, 180);
				linphone_proxy_config_enable_quality_reporting(proxy, TRUE);
			}
			proxies = proxies->next;
		}
		[self lpConfigSetBool:TRUE forKey:@"quality_report_migration_done"];
	}
	/* File transfer migration */
	if ([self lpConfigBoolForKey:@"file_transfer_migration_done"] == FALSE) {
		const char *newURL = "https://www.linphone.org:444/lft.php";
		LOGI(@"Migrating sharing server url from %s to %s", linphone_core_get_file_transfer_server(LC), newURL);
		linphone_core_set_file_transfer_server(LC, newURL);
		[self lpConfigSetBool:TRUE forKey:@"file_transfer_migration_done"];
	}
}

static void migrateWizardToAssistant(const char *entry, void *user_data) {
	LinphoneManager *thiz = (__bridge LinphoneManager *)(user_data);
	NSString *key = [NSString stringWithUTF8String:entry];
	[thiz lpConfigSetString:[thiz lpConfigStringForKey:key inSection:@"wizard"] forKey:key inSection:@"assistant"];
}

- (void)migratePushNotificationPerAccount {
	NSString *s = [self lpConfigStringForKey:@"pushnotification_preference"];
	if (s && s.boolValue) {
		LOGI(@"Migrating push notification per account, enabling for ALL");
		[self lpConfigSetBool:NO forKey:@"pushnotification_preference"];
		const MSList *proxies = linphone_core_get_proxy_config_list(LC);
		while (proxies) {
			linphone_proxy_config_set_ref_key(proxies->data, "push_notification");
			[self configurePushTokenForProxyConfig:proxies->data];
			proxies = proxies->next;
		}
	}
}

#pragma mark - Linphone Core Functions

+ (LinphoneCore *)getLc {
	if (theLinphoneCore == nil) {
        KLog1(@"theLinphoneCore is null");
        
		@throw([NSException exceptionWithName:@"LinphoneCoreException"
									   reason:@"Linphone core not initialized yet"
									 userInfo:nil]);
	}
	return theLinphoneCore;
}

#pragma mark Debug functions

+ (void)dumpLcConfig {
	if (theLinphoneCore) {
		LpConfig *conf = LinphoneManager.instance.configDb;
		char *config = lp_config_dump(conf);
		LOGI(@"\n%s", config);
		ms_free(config);
	}
}

#pragma mark - Logs Functions handlers
static void linphone_iphone_log_user_info(struct _LinphoneCore *lc, const char *message) {
	linphone_iphone_log_handler(NULL, ORTP_MESSAGE, message, NULL);
}
static void linphone_iphone_log_user_warning(struct _LinphoneCore *lc, const char *message) {
	linphone_iphone_log_handler(NULL, ORTP_WARNING, message, NULL);
}

#pragma mark - Display Status Functions
/* CMP
- (void)displayStatus:(NSString *)message {
	// Post event
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneDisplayStatusUpdate
													  object:self
													userInfo:@{
														@"message" : message
													}];
}*/

static void linphone_iphone_display_status(struct _LinphoneCore *lc, const char *message) {
	//NSString *status = [[NSString alloc] initWithCString:message encoding:[NSString defaultCStringEncoding]];
	//CMP [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) displayStatus:status];
}

/* CMP
#pragma mark - Call State Functions

- (void)localNotifContinue:(NSTimer *)timer {
	UILocalNotification *notif = [timer userInfo];
	if (notif) {
		LOGI(@"cancelling/presenting local notif");
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		[[UIApplication sharedApplication] presentLocalNotificationNow:notif];
	}
}

- (void)userNotifContinue:(NSTimer *)timer {
    UNNotificationContent *content = [timer userInfo];
	if (content && [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		LOGI(@"cancelling/presenting user notif");
		UNNotificationRequest *req =
			[UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
		[[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req
															   withCompletionHandler:^(NSError *_Nullable error) {
																 // Enable or disable features based on authorization.
																 if (error) {
																	 LOGD(@"Error while adding notification request :");
																	 LOGD(error.description);
																 }
															   }];
	}
}*/

- (void)onCall:(LinphoneCall *)call StateChanged:(LinphoneCallState)state withMessage:(const char *)message {
    
    KLog(@"oncall. state=%d, message=%s",state, message);
    EnLogd(@"oncall. state=%d, message=%s",state, message);
    
	// Handling wrapper
    NSString* callId = @"";
    NSString* toNumber = @"";
    
    linphone_call_enable_echo_cancellation(call,TRUE);//CMP
	LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
	if (!data) {
		data = [[LinphoneCallAppData alloc] init];
		linphone_call_set_user_data(call, (void *)CFBridgingRetain(data));
        NSDictionary* userInfo =  data->userInfos;
        KLog(@"userInfo = %@",userInfo);
	}

#pragma deploymate push "ignored-api-availability"
	if (_silentPushCompletion) {
		// we were woken up by a silent push. Call the completion handler with NEWDATA
		// so that the push is notified to the user
		LOGI(@"onCall - handler %p", _silentPushCompletion);
		_silentPushCompletion(UIBackgroundFetchResultNewData);
		_silentPushCompletion = nil;
	}
#pragma deploymate pop

    //- The following is the ideal way of getting caller address. TODO discuss with the server team.
    /*NOV 2017. TODO comment this in release code
    const LinphoneAddress *addr = linphone_call_get_remote_address(call);
    const char *lUserName = linphone_address_get_username(addr);
    NSString* address = [NSString stringWithUTF8String:lUserName];
    KLog(@"userName: %@",address);
    */
    
    if (state == LinphoneCallIncomingReceived) {
        EnLogd(@"Incoming call");
        const LinphoneCallParams* callParams = linphone_call_get_remote_params(call);
        //Custom header that specifies To number
        const char* toContact = linphone_call_params_get_custom_header(callParams, @"div".UTF8String);
        if(toContact && strlen(toContact))
            toNumber = [NSString stringWithUTF8String:toContact];
        sToNumber = toNumber;
        //NSLog(@"custHeader = %s",toContact);
        
        /* NOV 2017, TODO: uncomment this in release code. */
         const char* fromContact = linphone_call_params_get_custom_header(callParams, @"divf".UTF8String);
         NSString* address=@"unknown";
         if(fromContact && strlen(fromContact))
         address = [NSString stringWithUTF8String:fromContact];
         //
        
        //- get the custom header "reason" which indicates the reason for incoming call.
        const char* reason = linphone_call_params_get_custom_header(callParams, @"divr".UTF8String);
        if(reason && strlen(reason)) {
            NSString* callReason = [NSString stringWithUTF8String:reason];
            NSMutableDictionary* reasonDic = [[NSMutableDictionary alloc]init];
            if(toNumber.length) {
                [reasonDic setValue:toNumber forKey:NATIVE_CONTACT_ID];
                [reasonDic setValue:callReason forKey:API_MISSEDCALL_REASON];
                [[Engine sharedEngineObj]updateMissedCallReason:reasonDic];
            } else {
                EnLogd(@"toNumber is nil. Check \"div\" header in INVITE.");
            }
        } else {
            EnLogd(@"Reason is nil. Check \"divr\" header in INVITE.");
        }
        //
        
        
        //- Dont allow blocked and voipcall blocked contacts
        NSUserDefaults* groupSettings = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.kirusa.InstaVoiceGroup"];
        NSMutableArray* phoneNumbers = [groupSettings objectForKey:@"PHONE_NUMBERS_BLKD"];
        if(phoneNumbers.count) {
            NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber* num = [f numberFromString:address];
            
            if([phoneNumbers containsObject:num]) {
                KLog(@"%@ has been blocked. Decline.",address);
                EnLogd(@"%@ has been blocked. Decline.",address);
                linphone_call_decline(call, LinphoneReasonBusy);
                return;
            }
        }
        
        if([self isVoipCallBlocked:toNumber]) {
            KLog(@"%@\'s reachMe disabled. Decline.",toNumber);
            EnLogd(@"%@\'s reachMe disabled. Decline.",toNumber);
            linphone_call_decline(call, LinphoneReasonBusy);
            return;
        }
        
        LinphoneCallLog *callLog = linphone_call_get_call_log(call);
        callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
        int index = [(NSNumber *)[_pushDict objectForKey:callId] intValue] - 1;
        LOGI(@"Decrementing index of long running task for call id : %@ with index : %d", callId, index);
        [_pushDict setValue:[NSNumber numberWithInt:index] forKey:callId];
        BOOL need_bg_task = FALSE;
        for (NSString *key in [_pushDict allKeys]) {
            int value = [(NSNumber *)[_pushDict objectForKey:key] intValue];
            if (value > 0) {
                need_bg_task = TRUE;
                break;
            }
        }
        if (pushBgTaskCall && !need_bg_task) {
            LOGI(@"Call received, stopping call background task for call-id [%@]", callId);
            [[UIApplication sharedApplication] endBackgroundTask:pushBgTaskCall];
            pushBgTaskCall = 0;
        }
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            
            if (call /*CMP
                      && (linphone_core_get_calls_nb(LC) < 2)*/) {
#if !TARGET_IPHONE_SIMULATOR
                          // CMP - Reject the second call
                          if(linphone_core_get_calls_nb(LC)>1) {
                              KLog(@"Rejecting the call.%@",callId);
                              LinphoneCall *call = [LinphoneManager.instance callByCallId:callId];
                              if(call) {
                                  KLog(@"Reject the call.Decline.");
                                  LOGI(@"Reject the call.Decline.");
                                  EnLogd(@"Reject the second call. Decline.");
                                  linphone_call_decline(call, LinphoneReasonDeclined);
                                  return;
                              }
                          }
                          self.callType = @"p2pin";
                          self.isReachMeHdrPresent = NO;
                          callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
                          //FEB 2018 [NSString stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(call))];
                          
                          NSUUID *uuid = [NSUUID UUID];
                          [LinphoneManager.instance.providerDelegate.calls setObject:callId forKey:uuid];
                          [LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:callId];
                          BOOL video = FALSE;
                          video = ([UIApplication sharedApplication].applicationState == UIApplicationStateActive &&
                                   linphone_core_get_video_policy(LC)->automatically_accept &&
                                   linphone_call_params_video_enabled(linphone_call_get_remote_params(call)));
                          [LinphoneManager.instance.providerDelegate reportIncomingCallwithUUID:uuid handle:address video:video];
                          KLog(@"incoming: %@",uuid);
                          
                          //- If Microphone access is not enabled, decline the call
                          //TODO: check this
                          if( ![self checkMicrophonePermission:nil] ) {
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                  linphone_call_decline(call, LinphoneReasonBusy);
                                  [self showMicrophoneAccessWarning:nil];
                              });
                          }

                          bitRate = 0;
                          clockRate = 0;
                          codec = @"";
                          thisCallLog = callLog;
                          bwUsage = @"";
                          
#else
                          //VOIP [PhoneMainView.instance displayIncomingCall:call];
#endif
                      } else if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                          
                          KLog(@"Incoming call");
                          // Create a UNNotification
                          /* CMP
                           UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                           content.title = NSLocalizedString(@"Incoming call", nil);
                           content.body = address;
                           content.sound = [UNNotificationSound soundNamed:@"notes_of_the_optimistic.caf"];
                           content.categoryIdentifier = @"call_cat";
                           content.userInfo = @{ @"CallId" : callId };
                           UNNotificationRequest *req =
                           [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
                           [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req
                           withCompletionHandler:^(NSError *err){
                           }];
                           */
                      }
        }
    }
    else if (/*state == LinphoneCallOutgoingInit || */ state == LinphoneCallOutgoingRinging) {
        self.isReachMeHdrPresent = NO;
        LinphoneCallLog *callLog = linphone_call_get_call_log(call);
        thisCallLog = callLog;
        /*
         callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
         NSUUID *uuid = [NSUUID UUID];
         [LinphoneManager.instance.providerDelegate.calls setObject:callId forKey:uuid];
         [LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:callId];
         KLog(@"state: %d, UUID:%@, callID: %@",state, uuid,callId);
         */
    }

	// we keep the speaker auto-enabled state in this static so that we don't
	// force-enable it on ICE re-invite if the user disabled it.
	static BOOL speaker_already_enabled = FALSE;

	// Disable speaker when no more call
	if ((state == LinphoneCallEnd || state == LinphoneCallError)) {
        
		speaker_already_enabled = FALSE;
		if (linphone_core_get_calls_nb(theLinphoneCore) == 0) {
			//CMP [self setSpeakerEnabled:FALSE];
			[self removeCTCallCenterCb];
			// disable this because I don't find anygood reason for it: _bluetoothAvailable = FALSE;
			// furthermore it introduces a bug when calling multiple times since route may not be
			// reconfigured between cause leading to bluetooth being disabled while it should not
			_bluetoothEnabled = FALSE;
			/*IOS specific*/
			linphone_core_start_dtmf_stream(theLinphoneCore);
		}

		if (incallBgTask) {
			[[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
			incallBgTask = 0;
		}

		if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
			if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
				if (data->timer) {
					[data->timer invalidate];
					data->timer = nil;
				}
				LinphoneCallLog *UNlog = linphone_call_get_call_log(call);
				BOOL notAnsweredElsewhere = TRUE;
				const LinphoneErrorInfo *ei = linphone_call_get_error_info(call);
				if (ei) {
					// error not between 200-299 or 600-699
					int code = linphone_error_info_get_protocol_code(ei);
					notAnsweredElsewhere = !((code >= 200 && code < 300) || (code >= 600 && code < 700));
				}
				if ((UNlog == NULL || linphone_call_log_get_status(UNlog) == LinphoneCallMissed ||
					 linphone_call_log_get_status(UNlog) == LinphoneCallAborted ||
					 linphone_call_log_get_status(UNlog) == LinphoneCallEarlyAborted) &&
					notAnsweredElsewhere) {
                    /* TODO CMP: Remove the local notification for missed call. Remove the handling part as well.
					UNMutableNotificationContent *missed_content = [[UNMutableNotificationContent alloc] init];
					missed_content.title = NSLocalizedString(@"Missed call", nil);
					missed_content.body = address;
					UNNotificationRequest *missed_req = [UNNotificationRequest requestWithIdentifier:@"call_request"
																							 content:missed_content
																							 trigger:NULL];
					[[UNUserNotificationCenter currentNotificationCenter]
						addNotificationRequest:missed_req
						 withCompletionHandler:^(NSError *_Nullable error) {
						   // Enable or disable features based on authorization.
						   if (error) {
							   LOGD(@"Error while adding notification request :");
							   LOGD(error.description);
						   }
						 }];*/
				}
				linphone_core_set_network_reachable(LC, FALSE);
				LinphoneManager.instance.connectivity = none;
			}
			LinphoneCallLog *callLog2 = linphone_call_get_call_log(call);
			const char *call_id2 = linphone_call_log_get_call_id(callLog2);
			NSString *callId2 = call_id2 ? [NSString stringWithUTF8String:call_id2] : @"";
			NSUUID *uuid = (NSUUID *)[self.providerDelegate.uuids objectForKey:callId2];
			if (uuid) {
				// For security reasons do not display name
				// CXCallUpdate *update = [[CXCallUpdate alloc] init];
				// update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"Unknown"];
				//[LinphoneManager.instance.providerDelegate.provider reportCallWithUUID:uuid updated:update];

				if (linphone_core_get_calls_nb(LC) > 0 && !_conf) {
					// Create a CallKit call because there's not !
					_conf = FALSE;
					LinphoneCall *callKit_call = (LinphoneCall *)linphone_core_get_calls(LC)->data;
					NSString *callKit_callId = [NSString
						stringWithUTF8String:linphone_call_log_get_call_id(linphone_call_get_call_log(callKit_call))];
					NSUUID *callKit_uuid = [NSUUID UUID];
					[LinphoneManager.instance.providerDelegate.uuids setObject:callKit_uuid forKey:callKit_callId];
					[LinphoneManager.instance.providerDelegate.calls setObject:callKit_callId forKey:callKit_uuid];
                    /*
					NSString *address =
						[FastAddressBook displayNameForAddress:linphone_call_get_remote_address(callKit_call)];
                     */
                    NSString* address = @"";
					CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:address];//TODO
					CXStartCallAction *act = [[CXStartCallAction alloc] initWithCallUUID:callKit_uuid handle:handle];
					CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
					[LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
																				  completion:^(NSError *err){
																				  }];
					[LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:callKit_uuid
																		   startedConnectingAtDate:nil];
					[LinphoneManager.instance.providerDelegate.provider reportOutgoingCallWithUUID:callKit_uuid
																				   connectedAtDate:nil];
				}

                KLog(@"Initiate EndCallAction: %@",uuid);
                EnLogd(@"remote-user ended the call");
				CXEndCallAction *act = [[CXEndCallAction alloc] initWithCallUUID:uuid];
				CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
				[LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
																			  completion:^(NSError *err) {
                                                                                  KLog(@"CXEndCallAction: %@",err);
																			  }];
			} else { // Can happen when Call-ID changes (Replaces header)
				if (linphone_core_get_calls_nb(LC) == 0) { // Need to clear all CK calls
					for(NSUUID *myUuid in self.providerDelegate.calls) {
						[self.providerDelegate.provider reportCallWithUUID:myUuid
															   endedAtDate:NULL
																	reason:(state == LinphoneCallError ? CXCallEndedReasonFailed : CXCallEndedReasonRemoteEnded)];
					}
					[self.providerDelegate.uuids removeAllObjects];
					[self.providerDelegate.calls removeAllObjects];
				}
			}
		}
		if (state == LinphoneCallError) {
            const LinphoneErrorInfo *ei = linphone_call_get_error_info(call);
            int errcode = 0;
            if (ei)
                errcode = linphone_error_info_get_protocol_code(ei);
                
			//CMP [PhoneMainView.instance popCurrentView];
            NSString* errMsg = [NSString stringWithUTF8String:message];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSString* alertMsg = nil;
                if(404 == errcode) {
                    if([errMsg isEqualToString:kErrCountry]) {
                        alertMsg = kObdWarning;
                    }
                    else if([errMsg containsString:kErrLowBalance]) {
                        alertMsg = kLowBalance;
                    } else if([errMsg isEqualToString:kErrNoDestination]) {
                        //- Initiate Registration
                        /* It it required? TODO
                        [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore] setRegAttempt:1];
                        [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore] refreshRegister:YES];
                         */
                    }
                }
                else if(500 == errcode) {
                    alertMsg = kErrServiceNotAvail;
                } else {
                    KLog(@"Error code: %d", errcode);
                    EnLogd(@"Error code: %d", errcode);
                    /*
                    const char* remContact = linphone_call_get_remote_contact(call);
                    KLog(@"remContact = %s", remContact);
                    KLog(@"message: %s", message);
                    if(301==errcode) {
                        LinphoneProxyConfig *config = linphone_core_get_default_proxy_config(LC);
                        linphone_proxy_config_set_server_addr(config, message);
                        linphone_proxy_config_set_route(config, message);
                        linphone_call_redirect(call, "<sip:918197277300@devreachme.instavoice.com>");
                    }*/
                }
                
                if(alertMsg.length)
                    [ScreenUtility showAlert:alertMsg];
            });
		}
	}

	if (state == LinphoneCallReleased) {
		if (data != NULL) {
            if(linphone_core_get_calls_nb(LC)==0) {
                if(callStatsTimer)
                    [callStatsTimer invalidate];
                [self rtpStats:call];
            }
			linphone_call_set_user_data(call, NULL);
			CFBridgingRelease((__bridge CFTypeRef)(data));
		}
	}

	// Enable speaker when video
    /* CMP
	if (state == LinphoneCallIncomingReceived || state == LinphoneCallOutgoingInit || state == LinphoneCallConnected ||
		state == LinphoneCallStreamsRunning) {
		if (linphone_call_params_video_enabled(linphone_call_get_current_params(call)) && !speaker_already_enabled) {
			[self setSpeakerEnabled:TRUE];
			speaker_already_enabled = TRUE;
		}
        KLog(@"Incoming call received. state=%d",state);
	}*/

	if (state == LinphoneCallConnected && !mCallCenter) {
        
        //- Get reachme header
        //- reachme:YES will be present in 200OK message at the caller side when outgoing call is connected with callee.
        //  otherwise reachme header will not be present.
        const LinphoneCallParams* callParams = linphone_call_get_remote_params(call);
        const char* reachmeHdr = linphone_call_params_get_custom_header(callParams, @"reachme".UTF8String);
        if(reachmeHdr && strlen(reachmeHdr))
            self.isReachMeHdrPresent = YES;
        else
            self.isReachMeHdrPresent = NO;
        //
        
		/*only register CT call center CB for connected call*/
		[self setupGSMInteraction];
        //self.showUserRating = NO;
        callStatsTimer = [NSTimer scheduledTimerWithTimeInterval:kCallStatsUpdateInterval
                                                          target:self
                                                        selector:@selector(callStatsUpdate)
                                                        userInfo:nil
                                                         repeats:YES];
	}
    /* OCT 3, 2017
    if(state == LinphoneCallResuming) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max && call) {
            NSUUID *uuid = (NSUUID *)[LinphoneManager.instance.providerDelegate.uuids
                                      objectForKey:[NSString stringWithUTF8String:linphone_call_log_get_call_id(
                                                                                                                linphone_call_get_call_log(call))]];
            if (!uuid) {
                return;
            }
            
            KLog(@"Calling performSetHeldCallAction:%@",uuid);
            CXSetHeldCallAction *act = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:NO];
            CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
            [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
                                                                          completion:^(NSError *err){
                                                                          }];
        }
    }*/

	
    // Post event
	NSDictionary *dict = @{
		@"call" : [NSValue valueWithPointer:call],
		@"state" : [NSNumber numberWithInt:state],
		@"message" : [NSString stringWithUTF8String:message],
        @"callId" : [NSString stringWithString:callId],
        @"toNumber": toNumber
	};
    
    KLog(@"callId:%@",callId);
    
    [LinphoneManager.instance.providerDelegate onCallStateChanged:dict];
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self userInfo:dict];
}

static void linphone_iphone_call_state(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state,
									   const char *message) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onCall:call StateChanged:state withMessage:message];
}

#pragma mark - Transfert State Functions

static void linphone_iphone_transfer_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState state) {
}

#pragma mark - Global state change

static void linphone_iphone_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onGlobalStateChanged:gstate withMessage:message];
}

- (void)onGlobalStateChanged:(LinphoneGlobalState)state withMessage:(const char *)message {
	LOGI(@"onGlobalStateChanged: %d (message: %s)", state, message);

	NSDictionary *dict = [NSDictionary
		dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state], @"state",
									 [NSString stringWithUTF8String:message ? message : ""], @"message", nil];

	// dispatch the notification asynchronously
	dispatch_async(dispatch_get_main_queue(), ^(void) {
	  [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneGlobalStateUpdate object:self userInfo:dict];
	});
}

- (void)globalStateChangedNotificationHandler:(NSNotification *)notif {
	if ((LinphoneGlobalState)[[[notif userInfo] valueForKey:@"state"] integerValue] == LinphoneGlobalOn) {
		[self finishCoreConfiguration];
	}
}

#pragma mark - Configuring status changed

static void linphone_iphone_configuring_status_changed(LinphoneCore *lc, LinphoneConfiguringState status,
													   const char *message) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onConfiguringStatusChanged:status withMessage:message];
}

- (void)onConfiguringStatusChanged:(LinphoneConfiguringState)status withMessage:(const char *)message {
	LOGI(@"onConfiguringStatusChanged: %s %@", linphone_configuring_state_to_string(status),
		 message ? [NSString stringWithFormat:@"(message: %s)", message] : @"");

	NSDictionary *dict = [NSDictionary
		dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:status], @"state",
									 [NSString stringWithUTF8String:message ? message : ""], @"message", nil];

	// dispatch the notification asynchronously
	dispatch_async(dispatch_get_main_queue(), ^(void) {
	  [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneConfiguringStateUpdate
														object:self
													  userInfo:dict];
	});
}

- (void)configuringStateChangedNotificationHandler:(NSNotification *)notif {
	_wasRemoteProvisioned = ((LinphoneConfiguringState)[[[notif userInfo] valueForKey:@"state"] integerValue] ==
							 LinphoneConfiguringSuccessful);
	if (_wasRemoteProvisioned) {
		LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
		if (cfg) {
			[self configurePushTokenForProxyConfig:cfg];
		}
	}
}

#pragma mark - Registration State Functions

- (void)onRegister:(LinphoneCore *)lc
			   cfg:(LinphoneProxyConfig *)cfg
			 state:(LinphoneRegistrationState)state
		   message:(const char *)cmessage {
	LOGI(@"New registration state: %s (message: %s)", linphone_registration_state_to_string(state), cmessage);
    KLog(@"New registration state: %s (message: %s)", linphone_registration_state_to_string(state), cmessage);

	LinphoneReason reason = linphone_proxy_config_get_error(cfg);
	NSString *message = nil;
	switch (reason) {
		case LinphoneReasonBadCredentials:
			message = NSLocalizedString(@"Bad credentials, check your account settings", nil);
			break;
		case LinphoneReasonNoResponse:
			message = NSLocalizedString(@"No response received from remote", nil);
			break;
		case LinphoneReasonUnsupportedContent:
			message = NSLocalizedString(@"Unsupported content", nil);
			break;
		case LinphoneReasonIOError:
			message = NSLocalizedString(
				@"Cannot reach the server: either it is an invalid address or it may be temporary down.", nil);
			break;

		case LinphoneReasonUnauthorized:
			message = NSLocalizedString(@"Operation is unauthorized because missing credential", nil);
			break;
		case LinphoneReasonNoMatch:
			message = NSLocalizedString(@"Operation could not be executed by server or remote client because it "
										@"didn't have any context for it",
										nil);
			break;
		case LinphoneReasonMovedPermanently:
			message = NSLocalizedString(@"Resource moved permanently", nil);
			break;
		case LinphoneReasonGone:
			message = NSLocalizedString(@"Resource no longer exists", nil);
			break;
		case LinphoneReasonTemporarilyUnavailable:
			message = NSLocalizedString(@"Temporarily unavailable", nil);
			break;
		case LinphoneReasonAddressIncomplete:
			message = NSLocalizedString(@"Address incomplete", nil);
			break;
		case LinphoneReasonNotImplemented:
			message = NSLocalizedString(@"Not implemented", nil);
			break;
		case LinphoneReasonBadGateway:
			message = NSLocalizedString(@"Bad gateway", nil);
			break;
		case LinphoneReasonServerTimeout:
			message = NSLocalizedString(@"Server timeout", nil);
			break;
		case LinphoneReasonNotAcceptable:
		case LinphoneReasonDoNotDisturb:
		case LinphoneReasonDeclined:
		case LinphoneReasonNotFound:
		case LinphoneReasonNotAnswered:
		case LinphoneReasonBusy:
		case LinphoneReasonNone:
		case LinphoneReasonUnknown:
			message = NSLocalizedString(@"Unknown error", nil);
			break;
	}

    //NSLog(@"message = %@",message);
    
	// Post event
	NSDictionary *dict =
		[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state], @"state",
												   [NSValue valueWithPointer:cfg], @"cfg", message, @"message", nil];
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneRegistrationUpdate object:self userInfo:dict];
}

static void linphone_iphone_registration_state(LinphoneCore *lc, LinphoneProxyConfig *cfg,
											   LinphoneRegistrationState state, const char *message) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onRegister:lc cfg:cfg state:state message:message];
}

#pragma mark - Auth info Function

static void linphone_iphone_popup_password_request(LinphoneCore *lc, const char *realmC, const char *usernameC,
												   const char *domainC) {
    
    KLog1(@"Registration failed. Check username/password");
#ifdef CMP_REMOVE
	// let the wizard handle its own errors
	if ([PhoneMainView.instance currentView] != AssistantView.compositeViewDescription) {
		static UIAlertController *alertView = nil;

		// avoid having multiple popups
		if ([alertView isBeingPresented]) {
			[alertView dismissViewControllerAnimated:YES completion:nil];
		}

		// dont pop up if we are in background, in any case we will refresh registers when entering
		// the application again
		if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
			return;
		}

		NSString *realm = [NSString stringWithUTF8String:realmC];
		NSString *username = [NSString stringWithUTF8String:usernameC];
		NSString *domain = [NSString stringWithUTF8String:domainC];
		alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Authentification needed", nil)
														message:[NSString stringWithFormat:NSLocalizedString(@"Registration failed because authentication is "
																											 @"missing or invalid for %@@%@.\nYou can "
																											 @"provide password again, or check your "
																											 @"account configuration in the settings.", nil), username, realm]
												 preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			textField.placeholder = NSLocalizedString(@"Password", nil);
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.borderStyle = UITextBorderStyleRoundedRect;
			textField.secureTextEntry = YES;
		}];
		
		UIAlertAction* continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm password", nil)
																 style:UIAlertActionStyleDefault
															   handler:^(UIAlertAction * action) {
																   NSString *password = alertView.textFields[0].text;
																   LinphoneAuthInfo *info =
																   linphone_auth_info_new(username.UTF8String, NULL, password.UTF8String, NULL,
																						  realm.UTF8String, domain.UTF8String);
																   linphone_core_add_auth_info(LC, info);
																   [LinphoneManager.instance refreshRegisters];
															   }];
		
		UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go to settings", nil)
																 style:UIAlertActionStyleDefault
															   handler:^(UIAlertAction * action) {
																   [PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
															   }];
		
		[alertView addAction:defaultAction];
		[alertView addAction:continueAction];
		[alertView addAction:settingsAction];
		[PhoneMainView.instance presentViewController:alertView animated:YES completion:nil];
	}
#endif
}

#pragma mark - Text Received Functions

- (void)onMessageReceived:(LinphoneCore *)lc room:(LinphoneChatRoom *)room message:(LinphoneChatMessage *)msg {
    
    KLog1(@"onMessageReceived: FIXME.");
    
#ifdef CMP_REMOVE
    
#pragma deploymate push "ignored-api-availability"
	if (_silentPushCompletion) {
		// we were woken up by a silent push. Call the completion handler with NEWDATA
		// so that the push is notified to the user
		LOGI(@"onMessageReceived - handler %p", _silentPushCompletion);
		_silentPushCompletion(UIBackgroundFetchResultNewData);
		_silentPushCompletion = nil;
	}
#pragma deploymate pop
	NSString *callID = [NSString stringWithUTF8String:linphone_chat_message_get_custom_header(msg, "Call-ID")];
	const LinphoneAddress *remoteAddress = linphone_chat_message_get_from_address(msg);
	NSString *from = [FastAddressBook displayNameForAddress:remoteAddress];

	char *c_address = linphone_address_as_string_uri_only(remoteAddress);
	NSString *remote_uri = [NSString stringWithUTF8String:c_address];
	ms_free(c_address);
	int index = [(NSNumber *)[_pushDict objectForKey:callID] intValue] - 1;
	LOGI(@"Decrementing index of long running task for call id : %@ with index : %d", callID, index);
	[_pushDict setValue:[NSNumber numberWithInt:index] forKey:callID];
	BOOL need_bg_task = FALSE;
	for (NSString *key in [_pushDict allKeys]) {
		int value = [(NSNumber *)[_pushDict objectForKey:key] intValue];
		if (value > 0) {
			need_bg_task = TRUE;
			break;
		}
	}
	if (pushBgTaskMsg && !need_bg_task) {
		LOGI(@"Message received, stopping message background task for call-id [%@]", callID);
		[[UIApplication sharedApplication] endBackgroundTask:pushBgTaskMsg];
		pushBgTaskMsg = 0;
	}

	if (linphone_chat_message_is_file_transfer(msg) || linphone_chat_message_is_text(msg)) {
		if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive ||
			((PhoneMainView.instance.currentView != ChatsListView.compositeViewDescription) &&
			 ((PhoneMainView.instance.currentView != ChatConversationView.compositeViewDescription))) ||
			(PhoneMainView.instance.currentView == ChatConversationView.compositeViewDescription &&
			 room != PhoneMainView.instance.currentRoom)) {
			// Create a new notification
			if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
				NSArray *actions;

				if ([[UIDevice.currentDevice systemVersion] floatValue] < 9 ||
					[LinphoneManager.instance lpConfigBoolForKey:@"show_msg_in_notif"] == NO) {

					UIMutableUserNotificationAction *reply = [[UIMutableUserNotificationAction alloc] init];
					reply.identifier = @"reply";
					reply.title = NSLocalizedString(@"Reply", nil);
					reply.activationMode = UIUserNotificationActivationModeForeground;
					reply.destructive = NO;
					reply.authenticationRequired = YES;

					UIMutableUserNotificationAction *mark_read = [[UIMutableUserNotificationAction alloc] init];
					mark_read.identifier = @"mark_read";
					mark_read.title = NSLocalizedString(@"Mark Read", nil);
					mark_read.activationMode = UIUserNotificationActivationModeBackground;
					mark_read.destructive = NO;
					mark_read.authenticationRequired = NO;

					actions = @[ mark_read, reply ];
				} else {
					// iOS 9 allows for inline reply. We don't propose mark_read in this case
					UIMutableUserNotificationAction *reply_inline = [[UIMutableUserNotificationAction alloc] init];

					reply_inline.identifier = @"reply_inline";
					reply_inline.title = NSLocalizedString(@"Reply", nil);
					reply_inline.activationMode = UIUserNotificationActivationModeBackground;
					reply_inline.destructive = NO;
					reply_inline.authenticationRequired = NO;
					reply_inline.behavior = UIUserNotificationActionBehaviorTextInput;

					actions = @[ reply_inline ];
				}

				UIMutableUserNotificationCategory *msgcat = [[UIMutableUserNotificationCategory alloc] init];
				msgcat.identifier = @"incoming_msg";
				[msgcat setActions:actions forContext:UIUserNotificationActionContextDefault];
				[msgcat setActions:actions forContext:UIUserNotificationActionContextMinimal];

				NSSet *categories = [NSSet setWithObjects:msgcat, nil];

				UIUserNotificationSettings *set = [UIUserNotificationSettings
					settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
									  UIUserNotificationTypeSound)
						  categories:categories];
				[[UIApplication sharedApplication] registerUserNotificationSettings:set];

				UILocalNotification *notif = [[UILocalNotification alloc] init];
				if (notif) {
					NSString *chat = [UIChatBubbleTextCell TextMessageForChat:msg];
					notif.repeatInterval = 0;
					if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
#pragma deploymate push "ignored-api-availability"
						notif.category = @"incoming_msg";
#pragma deploymate pop
					}
					if ([LinphoneManager.instance lpConfigBoolForKey:@"show_msg_in_notif" withDefault:YES]) {
						notif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"IM_FULLMSG", nil), from, chat];
					} else {
						notif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"IM_MSG", nil), from];
					}
					notif.alertAction = NSLocalizedString(@"Show", nil);
					notif.soundName = @"msg.caf";
					notif.userInfo = @{ @"from" : from, @"from_addr" : remote_uri, @"call-id" : callID };
					notif.accessibilityLabel = @"Message notif";
					[[UIApplication sharedApplication] presentLocalNotificationNow:notif];
				}
			} else {
				// Msg category
				UNTextInputNotificationAction *act_reply =
					[UNTextInputNotificationAction actionWithIdentifier:@"Reply"
																  title:NSLocalizedString(@"Reply", nil)
																options:UNNotificationActionOptionNone];
				UNNotificationAction *act_seen =
					[UNNotificationAction actionWithIdentifier:@"Seen"
														 title:NSLocalizedString(@"Mark as seen", nil)
													   options:UNNotificationActionOptionNone];
				UNNotificationCategory *cat_msg =
					[UNNotificationCategory categoryWithIdentifier:@"msg_cat"
														   actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
												 intentIdentifiers:[[NSMutableArray alloc] init]
														   options:UNNotificationCategoryOptionCustomDismissAction];

				[[UNUserNotificationCenter currentNotificationCenter]
					requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
													 UNAuthorizationOptionBadge)
								  completionHandler:^(BOOL granted, NSError *_Nullable error) {
									// Enable or disable features based on authorization.
									if (error) {
										LOGD(error.description);
									}
								  }];
				NSSet *categories = [NSSet setWithObjects:cat_msg, nil];
				[[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
				UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
				content.title = NSLocalizedString(@"Message received", nil);
				if ([LinphoneManager.instance lpConfigBoolForKey:@"show_msg_in_notif" withDefault:YES]) {
					content.subtitle = from;
					content.body = [UIChatBubbleTextCell TextMessageForChat:msg];
				} else {
					content.body = from;
				}
				content.sound = [UNNotificationSound soundNamed:@"msg.caf"];
				content.categoryIdentifier = @"msg_cat";
				content.userInfo = @{ @"from" : from, @"from_addr" : remote_uri, @"CallId" : callID };
				content.accessibilityLabel = @"Message notif";
				UNNotificationRequest *req =
					[UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
				[[UNUserNotificationCenter currentNotificationCenter]
					addNotificationRequest:req
					 withCompletionHandler:^(NSError *_Nullable error) {
					   // Enable or disable features based on authorization.
					   if (error) {
						   LOGD(@"Error while adding notification request :");
						   LOGD(error.description);
					   }
					 }];
			}
		}
		// Post event
		NSDictionary *dict = @{
			@"room" : [NSValue valueWithPointer:room],
			@"from_address" : [NSValue valueWithPointer:linphone_chat_message_get_from_address(msg)],
			@"message" : [NSValue valueWithPointer:msg],
			@"call-id" : callID
		};

		[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneMessageReceived object:self userInfo:dict];
	}
#endif
}

static void linphone_iphone_message_received(LinphoneCore *lc, LinphoneChatRoom *room, LinphoneChatMessage *message) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onMessageReceived:lc room:room message:message];
}

static void linphone_iphone_message_received_unable_decrypt(LinphoneCore *lc, LinphoneChatRoom *room,
															LinphoneChatMessage *message) {

    return;
    
#ifdef CMP_NOT_USED
	NSString *msgId = [NSString stringWithUTF8String:linphone_chat_message_get_custom_header(message, "Call-ID")];

	int index = [(NSNumber *)[LinphoneManager.instance.pushDict objectForKey:msgId] intValue] - 1;
	LOGI(@"Decrementing index of long running task for call id : %@ with index : %d", msgId, index);
	[LinphoneManager.instance.pushDict setValue:[NSNumber numberWithInt:index] forKey:msgId];
	BOOL need_bg_task = FALSE;
	for (NSString *key in [LinphoneManager.instance.pushDict allKeys]) {
		int value = [(NSNumber *)[LinphoneManager.instance.pushDict objectForKey:key] intValue];
		if (value > 0) {
			need_bg_task = TRUE;
			break;
		}
	}
	if (theLinphoneManager->pushBgTaskMsg && !need_bg_task) {
		LOGI(@"Message received, stopping message background task for call-id [%@]", msgId);
		[[UIApplication sharedApplication] endBackgroundTask:theLinphoneManager->pushBgTaskMsg];
		theLinphoneManager->pushBgTaskMsg = 0;
	}
	const LinphoneAddress *address = linphone_chat_message_get_peer_address(message);
	//CMP NSString *strAddr = [FastAddressBook displayNameForAddress:address];
    NSString* strAddr = @"";
	NSString *title = NSLocalizedString(@"LIME warning", nil);
	NSString *body = [NSString
		stringWithFormat:NSLocalizedString(@"You have received an encrypted message you are unable to decrypt from "
										   @"%@.\nYou need to call your correspondant in order to exchange your ZRTP "
										   @"keys if you want to decrypt the future messages you will receive.",
										   nil),
						 strAddr];
	NSString *action = NSLocalizedString(@"Call", nil);

	if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
		if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
			UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
			content.title = title;
			content.body = body;
			UNNotificationRequest *req =
				[UNNotificationRequest requestWithIdentifier:@"decrypt_request" content:content trigger:NULL];
			[[UNUserNotificationCenter currentNotificationCenter]
				addNotificationRequest:req
				 withCompletionHandler:^(NSError *_Nullable error) {
				   // Enable or disable features based on authorization.
				   if (error) {
					   LOGD(@"Error while adding notification request :");
					   LOGD(error.description);
				   }
				 }];
		} else {
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.repeatInterval = 0;
			notification.alertTitle = title;
			notification.alertBody = body;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
	} else {
		UIAlertController *errView =
			[UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction *action){
															  }];

		UIAlertAction *callAction = [UIAlertAction actionWithTitle:action
															 style:UIAlertActionStyleDefault
														   handler:^(UIAlertAction *action) {
															 [LinphoneManager.instance call:address];
														   }];

		[errView addAction:defaultAction];
		[errView addAction:callAction];
		//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
	}
#endif
}

- (void)onNotifyReceived:(LinphoneCore *)lc
				   event:(LinphoneEvent *)lev
			 notifyEvent:(const char *)notified_event
				 content:(const LinphoneContent *)body {
	// Post event
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSValue valueWithPointer:lev] forKey:@"event"];
	[dict setObject:[NSString stringWithUTF8String:notified_event] forKey:@"notified_event"];
	if (body != NULL) {
		[dict setObject:[NSValue valueWithPointer:body] forKey:@"content"];
	}
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneNotifyReceived object:self userInfo:dict];
}

static void linphone_iphone_notify_received(LinphoneCore *lc, LinphoneEvent *lev, const char *notified_event,
											const LinphoneContent *body) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onNotifyReceived:lc
																			event:lev
																	  notifyEvent:notified_event
																		  content:body];
}

- (void)onNotifyPresenceReceivedForUriOrTel:(LinphoneCore *)lc
									 friend:(LinphoneFriend *)lf
										uri:(const char *)uri
							  presenceModel:(const LinphonePresenceModel *)model {
	// Post event
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSValue valueWithPointer:lf] forKey:@"friend"];
	[dict setObject:[NSValue valueWithPointer:uri] forKey:@"uri"];
	[dict setObject:[NSValue valueWithPointer:model] forKey:@"presence_model"];
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneNotifyPresenceReceivedForUriOrTel
													  object:self
													userInfo:dict];
}

static void linphone_iphone_notify_presence_received_for_uri_or_tel(LinphoneCore *lc, LinphoneFriend *lf,
																	const char *uri_or_tel,
																	const LinphonePresenceModel *presence_model) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onNotifyPresenceReceivedForUriOrTel:lc
																							  friend:lf
																								 uri:uri_or_tel
																					   presenceModel:presence_model];
}

static void linphone_iphone_call_encryption_changed(LinphoneCore *lc, LinphoneCall *call, bool_t on,
													const char *authentication_token) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onCallEncryptionChanged:lc
																					call:call
																					  on:on
																				   token:authentication_token];
}

//DEC 2017
static void linphone_core_network_reachable(LinphoneCore *lc, bool_t reachable) {
    
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onIPNetworkChanged:reachable];
}


/* TODO -- remove later
 This will be called on every packet received/sent
 */
/*
static void linphone_call_status_update(LinphoneCore *lc, LinphoneCall *call, const LinphoneCallStats *stats) {
    [(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onCallStatusUpdate:stats Call:call];
}*/


#ifdef REACHME_APP
//#define CALL_STATS
#ifdef CALL_STATS
-(void)onCallStatusUpdate:(const LinphoneCallStats*)stats Call:(LinphoneCall*)call {
 
    KLog(@"onCallStatusUpdate");
    float callQuality = linphone_call_get_current_quality(call);
    
    LinphoneCallStats* callStats = linphone_call_get_stats(call, LinphoneStreamTypeAudio);
    float senderLossRate = linphone_call_stats_get_sender_loss_rate(callStats);
    float recvrLossRate = linphone_call_stats_get_receiver_loss_rate(callStats);
    float senderInterArrivalJitter = linphone_call_stats_get_sender_interarrival_jitter(callStats);
    float recvrInterArrivalJitter = linphone_call_stats_get_receiver_interarrival_jitter(callStats);
    uint64_t cumLatePackets = linphone_call_stats_get_late_packets_cumulative_number(callStats);
    float downloadBW = linphone_call_stats_get_download_bandwidth(callStats);
    float uploadBW = linphone_call_stats_get_upload_bandwidth(callStats);
    float jitterBufSize = linphone_call_stats_get_jitter_buffer_size_ms(callStats);
    float rtdelay = linphone_call_stats_get_round_trip_delay(callStats); //in seconds
    
    if(!codec.length) {
        const LinphoneCallParams* callParams = linphone_call_get_current_params(call);
        const OrtpPayloadType* pt = linphone_call_params_get_used_audio_codec(callParams);
        const char* mime = payload_type_get_mime(pt);
        codec = [NSString stringWithUTF8String:mime];

        bitRate = payload_type_get_bitrate(pt);
        clockRate = payload_type_get_rate(pt);
    }
    
    /*
    const LinphoneCallParams* cp =  linphone_call_params_copy(callParams);
    LinphonePayloadType* pt1 =  linphone_call_params_get_used_audio_payload_type(cp);
    const char* encDesc = linphone_payload_type_get_encoder_description(pt1);
    const char *sfmtp = linphone_payload_type_get_send_fmtp(pt1);
    const char *rfmtp = linphone_payload_type_get_recv_fmtp(pt1);
    int channel = linphone_payload_type_get_channels(pt1);
    int clkrate = linphone_payload_type_get_clock_rate(pt1);
    int ptimeDownload = linphone_core_get_download_ptime(theLinphoneCore);
    int ptimeUpload = linphone_core_get_upload_ptime(theLinphoneCore);
    */

    KLog1(@"mime = %@",codec);
    KLog1(@"current call quality: %f",callQuality);
    KLog1(@"sender Loss rate: %f", senderLossRate);
    KLog1(@"receiver loss rate: %f", recvrLossRate);
    KLog1(@"sender interarrival jitter: %f",senderInterArrivalJitter);
    KLog1(@"reciever interarrival jitter: %f",recvrInterArrivalJitter);
    KLog1(@"cumulative late packets: %llu",cumLatePackets);
    KLog1(@"download BW: %f",downloadBW);
    KLog1(@"upload BW: %f",uploadBW);
    KLog1(@"jitter buffer size: %f", jitterBufSize);
    KLog1(@"round trip delay: %f", rtdelay);
    
}
#endif
#endif

- (void)onIPNetworkChanged:(BOOL)isNetReachable {
    
    KLog(@"onIPNetworkChanged:isReachable = %d",isNetReachable);
    // Post event
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithBool:isNetReachable] forKey:@"NetReachable"];
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneNetworkReachable object:self userInfo:dict];
}

- (void)onCallEncryptionChanged:(LinphoneCore *)lc
						   call:(LinphoneCall *)call
							 on:(BOOL)on
						  token:(const char *)authentication_token {
	// Post event
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSValue valueWithPointer:call] forKey:@"call"];
	[dict setObject:[NSNumber numberWithBool:on] forKey:@"on"];
	if (authentication_token) {
		[dict setObject:[NSString stringWithUTF8String:authentication_token] forKey:@"token"];
	}
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallEncryptionChanged object:self userInfo:dict];
}

#ifdef CMP_REMOVE
#pragma mark - Message composition start
- (void)alertLIME:(LinphoneChatRoom *)room {
	NSString *title = NSLocalizedString(@"LIME warning", nil);
	NSString *body =
		NSLocalizedString(@"You are trying to send a message using LIME to a contact not verified by ZRTP.\n"
						  @"Please call this contact and verify his ZRTP key before sending your messages.",
						  nil);

	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		UIAlertController *errView =
			[UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction *action){
															  }];
		[errView addAction:defaultAction];

		UIAlertAction *callAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Call", nil)
															 style:UIAlertActionStyleDefault
														   handler:^(UIAlertAction *action) {
															 [self call:linphone_chat_room_get_peer_address(room)];
														   }];
		[errView addAction:callAction];
		//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
	} else {
		if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
			UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
			content.title = title;
			content.body = body;
			content.categoryIdentifier = @"lime";

			UNNotificationRequest *req = [UNNotificationRequest
				requestWithIdentifier:@"lime_request"
							  content:content
							  trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO]];
			[[UNUserNotificationCenter currentNotificationCenter]
				addNotificationRequest:req
				 withCompletionHandler:^(NSError *_Nullable error) {
				   // Enable or disable features based on authorization.
				   if (error) {
					   LOGD(@"Error while adding notification request :");
					   LOGD(error.description);
				   }
				 }];
		} else {
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.repeatInterval = 0;
			notification.alertTitle = title;
			notification.alertBody = body;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
	}
}
#endif

- (void)onMessageComposeReceived:(LinphoneCore *)core forRoom:(LinphoneChatRoom *)room {
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneTextComposeEvent
													  object:self
													userInfo:@{
														@"room" : [NSValue valueWithPointer:room]
													}];
}

static void linphone_iphone_is_composing_received(LinphoneCore *lc, LinphoneChatRoom *room) {
	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onMessageComposeReceived:lc forRoom:room];
}

#pragma mark - Network Functions

- (SCNetworkReachabilityRef)getProxyReachability {
	return proxyReachability;
}

+ (void)kickOffNetworkConnection {
	static BOOL in_progress = FALSE;
	if (in_progress) {
		LOGW(@"Connection kickoff already in progress");
		return;
	}
	in_progress = TRUE;
	/* start a new thread to avoid blocking the main ui in case of peer host failure */
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	  static int sleep_us = 10000;
	  static int timeout_s = 5;
	  BOOL timeout_reached = FALSE;
	  int loop = 0;
	  CFWriteStreamRef writeStream;
	  CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef) @"192.168.0.200" /*"linphone.org"*/, 15000, nil,
										 &writeStream);
	  BOOL res = CFWriteStreamOpen(writeStream);
	  const char *buff = "hello";
	  time_t start = time(NULL);
	  time_t loop_time;

	  if (res == FALSE) {
		  LOGI(@"Could not open write stream, backing off");
		  CFRelease(writeStream);
		  in_progress = FALSE;
		  return;
	  }

	  // check stream status and handle timeout
	  CFStreamStatus status = CFWriteStreamGetStatus(writeStream);
	  while (status != kCFStreamStatusOpen && status != kCFStreamStatusError) {
		  usleep(sleep_us);
		  status = CFWriteStreamGetStatus(writeStream);
		  loop_time = time(NULL);
		  if (loop_time - start >= timeout_s) {
			  timeout_reached = TRUE;
			  break;
		  }
		  loop++;
	  }

	  if (status == kCFStreamStatusOpen) {
		  CFWriteStreamWrite(writeStream, (const UInt8 *)buff, strlen(buff));
	  } else if (!timeout_reached) {
		  CFErrorRef error = CFWriteStreamCopyError(writeStream);
		  LOGD(@"CFStreamError: %@", error);
		  CFRelease(error);
	  } else if (timeout_reached) {
		  LOGI(@"CFStream timeout reached");
	  }
	  CFWriteStreamClose(writeStream);
	  CFRelease(writeStream);
	  in_progress = FALSE;
	});
}

+ (NSString *)getCurrentWifiSSID {
#if TARGET_IPHONE_SIMULATOR
	return @"Sim_err_SSID_NotSupported";
#else
	NSString *data = nil;
	CFDictionaryRef dict = CNCopyCurrentNetworkInfo((CFStringRef) @"en0");
	if (dict) {
		LOGI(@"AP Wifi: %@", dict);
		data = [NSString stringWithString:(NSString *)CFDictionaryGetValue(dict, @"SSID")];
		CFRelease(dict);
	}
	return data;
#endif
}

static void showNetworkFlags(SCNetworkReachabilityFlags flags) {
	NSMutableString *log = [[NSMutableString alloc] initWithString:@"Network connection flags: "];
	if (flags == 0)
		[log appendString:@"no flags."];
	if (flags & kSCNetworkReachabilityFlagsTransientConnection)
		[log appendString:@"kSCNetworkReachabilityFlagsTransientConnection, "];
	if (flags & kSCNetworkReachabilityFlagsReachable)
		[log appendString:@"kSCNetworkReachabilityFlagsReachable, "];
	if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
		[log appendString:@"kSCNetworkReachabilityFlagsConnectionRequired, "];
	if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)
		[log appendString:@"kSCNetworkReachabilityFlagsConnectionOnTraffic, "];
	if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)
		[log appendString:@"kSCNetworkReachabilityFlagsConnectionOnDemand, "];
	if (flags & kSCNetworkReachabilityFlagsIsLocalAddress)
		[log appendString:@"kSCNetworkReachabilityFlagsIsLocalAddress, "];
	if (flags & kSCNetworkReachabilityFlagsIsDirect)
		[log appendString:@"kSCNetworkReachabilityFlagsIsDirect, "];
	if (flags & kSCNetworkReachabilityFlagsIsWWAN)
		[log appendString:@"kSCNetworkReachabilityFlagsIsWWAN, "];
	LOGI(@"%@", log);
}

//This callback keeps tracks of wifi SSID changes.
static void networkReachabilityNotification(CFNotificationCenterRef center, void *observer, CFStringRef name,
											const void *object, CFDictionaryRef userInfo) {
	LinphoneManager *mgr = LinphoneManager.instance;
	SCNetworkReachabilityFlags flags;

	// for an unknown reason, we are receiving multiple time the notification, so
	// we will skip each time the SSID did not change
	NSString *newSSID = [LinphoneManager getCurrentWifiSSID];
	if ([newSSID compare:mgr.SSID] == NSOrderedSame)
		return;

	
	if (newSSID != Nil && newSSID.length > 0 && mgr.SSID != Nil && newSSID.length > 0){
		if (SCNetworkReachabilityGetFlags([mgr getProxyReachability], &flags)) {
			LOGI(@"Wifi SSID changed, resesting transports.");
			mgr.connectivity=none; //this will trigger a connectivity change in networkReachabilityCallback.
			networkReachabilityCallBack([mgr getProxyReachability], flags, nil);
		}
	}
	mgr.SSID = newSSID;

	
}

void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *nilCtx) {
	showNetworkFlags(flags);
	LinphoneManager *lm = LinphoneManager.instance;
	SCNetworkReachabilityFlags networkDownFlags = kSCNetworkReachabilityFlagsConnectionRequired |
												  kSCNetworkReachabilityFlagsConnectionOnTraffic |
												  kSCNetworkReachabilityFlagsConnectionOnDemand;

	if (theLinphoneCore != nil) {
		LinphoneProxyConfig *proxy = linphone_core_get_default_proxy_config(theLinphoneCore);

		struct NetworkReachabilityContext *ctx = nilCtx ? ((struct NetworkReachabilityContext *)nilCtx) : 0;
		if ((flags == 0) || (flags & networkDownFlags)) {
			linphone_core_set_network_reachable(theLinphoneCore, false);
			lm.connectivity = none;
			[LinphoneManager kickOffNetworkConnection];
		} else {
			Connectivity newConnectivity;
			BOOL isWifiOnly = [lm lpConfigBoolForKey:@"wifi_only_preference" withDefault:FALSE];
			if (!ctx || ctx->testWWan)
				newConnectivity = flags & kSCNetworkReachabilityFlagsIsWWAN ? wwan : wifi;
			else
				newConnectivity = wifi;

			if (newConnectivity == wwan && proxy && isWifiOnly &&
				(lm.connectivity == newConnectivity || lm.connectivity == none)) {
				linphone_proxy_config_expires(proxy, 0);
			} else if (proxy) {
				NSInteger defaultExpire = [lm lpConfigIntForKey:@"default_expires"];
				if (defaultExpire >= 0)
					linphone_proxy_config_expires(proxy, (int)defaultExpire);
				// else keep default value from linphonecore
			}

			if (lm.connectivity != newConnectivity) {
				// connectivity has changed
				linphone_core_set_network_reachable(theLinphoneCore, false);
				if (newConnectivity == wwan && proxy && isWifiOnly) {
					linphone_proxy_config_expires(proxy, 0);
				}
				linphone_core_set_network_reachable(theLinphoneCore, true);
				linphone_core_iterate(theLinphoneCore);
				LOGI(@"Network connectivity changed to type [%s]", (newConnectivity == wifi ? "wifi" : "wwan"));
				lm.connectivity = newConnectivity;
			}
		}
		if (ctx && ctx->networkStateChanged) {
			(*ctx->networkStateChanged)(lm.connectivity);
		}
	}
}

- (void)setupNetworkReachabilityCallback {
	SCNetworkReachabilityContext *ctx = NULL;
	// any internet cnx
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;

	if (proxyReachability) {
		LOGI(@"Cancelling old network reachability");
		SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		CFRelease(proxyReachability);
		proxyReachability = nil;
	}

	// This notification is used to detect SSID change (switch of Wifi network). The ReachabilityCallback is
	// not triggered when switching between 2 private Wifi...
	// Since we cannot be sure we were already observer, remove ourself each time... to be improved
	_SSID = [LinphoneManager getCurrentWifiSSID];
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self),
									   CFSTR("com.apple.system.config.network_change"), NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self),
									networkReachabilityNotification, CFSTR("com.apple.system.config.network_change"),
									NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	proxyReachability =
		SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);

	if (!SCNetworkReachabilitySetCallback(proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack,
										  ctx)) {
		LOGE(@"Cannot register reachability cb: %s", SCErrorString(SCError()));
		return;
	}
	if (!SCNetworkReachabilityScheduleWithRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
		LOGE(@"Cannot register schedule reachability cb: %s", SCErrorString(SCError()));
		return;
	}

	// this check is to know network connectivity right now without waiting for a change. Don'nt remove it unless you
	// have good reason. Jehan
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(proxyReachability, &flags)) {
		networkReachabilityCallBack(proxyReachability, flags, nil);
	}
}

- (NetworkType)network {
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		UIApplication *app = [UIApplication sharedApplication];
		NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
		NSNumber *dataNetworkItemView = nil;

		for (id subview in subviews) {
			if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
				dataNetworkItemView = subview;
				break;
			}
		}

		NSNumber *number = (NSNumber *)[dataNetworkItemView valueForKey:@"dataNetworkType"];
		return [number intValue];
	} else {
#pragma deploymate push "ignored-api-availability"
		CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
		NSString *currentRadio = info.currentRadioAccessTechnology;
		if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge]) {
			return network_2g;
		} else if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
			return network_4g;
		}
#pragma deploymate pop
		return network_3g;
	}
}

#pragma mark - VTable

static LinphoneCoreVTable linphonec_vtable = {
	.call_state_changed = (LinphoneCoreCallStateChangedCb)linphone_iphone_call_state,
	.registration_state_changed = linphone_iphone_registration_state,
	.notify_presence_received_for_uri_or_tel = linphone_iphone_notify_presence_received_for_uri_or_tel,
	.auth_info_requested = linphone_iphone_popup_password_request,
	.message_received = linphone_iphone_message_received,
	.message_received_unable_decrypt = linphone_iphone_message_received_unable_decrypt,
	.transfer_state_changed = linphone_iphone_transfer_state_changed,
	.is_composing_received = linphone_iphone_is_composing_received,
	.configuring_status = linphone_iphone_configuring_status_changed,
	.global_state_changed = linphone_iphone_global_state_changed,
	.notify_received = linphone_iphone_notify_received,
	.call_encryption_changed = linphone_iphone_call_encryption_changed,
    .network_reachable = linphone_core_network_reachable
    //.call_stats_updated = linphone_call_status_update //TODO -- remove
};

#pragma mark -

// scheduling loop
- (void)iterate {
	linphone_core_iterate(theLinphoneCore);
}

- (void)audioSessionInterrupted:(NSNotification *)notification {
	int interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
	if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
		[self beginInterruption];
	} else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
		[self endInterruption];
	}
}

//July 19, 2018
-(void)resetUserAgentString {
    userAgentString = @"";
}

-(void)setUserAgentString {
    
    if(userAgentString.length) {
        return;
    }
    
    NSString* devID = [self getDeviceID];
    if(devID.length>1)
        devID = [devID stringByAppendingString:@"-"];
    else
        devID = @"";
    
    NSString *device = [[NSMutableString alloc]
                        initWithString:[NSString
                                        stringWithFormat:@"%@%@_%@_iOS%@",
                                        devID,
                                        [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                                        [VoipUtils deviceModelIdentifier],
                                        UIDevice.currentDevice.systemVersion]];
    device = [device stringByReplacingOccurrencesOfString:@"," withString:@"."];
    device = [device stringByReplacingOccurrencesOfString:@" " withString:@"."];
    if(devID.length) {
        userAgentString = [[NSString alloc]initWithString:device];
    }
    NSString* clientAppVer = CLIENT_APP_VER;
    linphone_core_set_user_agent(theLinphoneCore, device.UTF8String, clientAppVer.UTF8String);
    EnLogd(@"setUserAgent:%@",userAgentString);
}
//

/** Should be called once per linphone_core_new() */
- (void)finishCoreConfiguration {

	// get default config from bundle
	NSString *zrtpSecretsFileName = [LinphoneManager documentFile:@"zrtp_secrets"];
	//CMP NSString *chatDBFileName = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];

    /* July 19, 2018
    NSString* devID = [self getDeviceID];
    if(devID.length>1)
        devID = [devID stringByAppendingString:@"-"];
    else
        devID = @"";
    
	NSString *device = [[NSMutableString alloc]
		initWithString:[NSString
						   stringWithFormat:@"%@%@_%@_iOS%@",
                                            devID,
											[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"],
											[VoipUtils deviceModelIdentifier],
											UIDevice.currentDevice.systemVersion]];
	device = [device stringByReplacingOccurrencesOfString:@"," withString:@"."];
	device = [device stringByReplacingOccurrencesOfString:@" " withString:@"."];
    NSString* clientAppVer = CLIENT_APP_VER;
    linphone_core_set_user_agent(theLinphoneCore, device.UTF8String, clientAppVer.UTF8String);
    */
    [self setUserAgentString];
	_contactSipField = [self lpConfigStringForKey:@"contact_im_type_value" withDefault:@"SIP"];
    
    /* CMP
	if (_fastAddressBook == nil) {
		_fastAddressBook = [[FastAddressBook alloc] init];
	}*/

	linphone_core_set_zrtp_secrets_file(theLinphoneCore, [zrtpSecretsFileName UTF8String]);
	/*CMP
    linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
	linphone_core_set_call_logs_database_path(theLinphoneCore, [chatDBFileName UTF8String]);
    */

	[self setupNetworkReachabilityCallback];

    /* CMP
	NSString *path = [LinphoneManager bundleFile:@"nowebcamCIF.jpg"];
	if (path) {
		const char *imagePath = [path UTF8String];
		LOGI(@"Using '%s' as source image for no webcam", imagePath);
		linphone_core_set_static_picture(theLinphoneCore, imagePath);
	}*/

	/*DETECT cameras*/
    /*CMP
	_frontCamId = _backCamId = nil;
	char **camlist = (char **)linphone_core_get_video_devices(theLinphoneCore);
	if (camlist) {
		for (char *cam = *camlist; *camlist != NULL; cam = *++camlist) {
			if (strcmp(FRONT_CAM_NAME, cam) == 0) {
				_frontCamId = cam;
				// great set default cam to front
				LOGI(@"Setting default camera [%s]", _frontCamId);
				linphone_core_set_video_device(theLinphoneCore, _frontCamId);
			}
			if (strcmp(BACK_CAM_NAME, cam) == 0) {
				_backCamId = cam;
			}
		}
	} else {
		LOGW(@"No camera detected!");
	}*/

	if (![LinphoneManager isNotIphone3G]) {
		PayloadType *pt = linphone_core_find_payload_type(theLinphoneCore, "SILK", 24000, -1);
		if (pt) {
			linphone_core_enable_payload_type(theLinphoneCore, pt, FALSE);
			LOGW(@"SILK/24000 and video disabled on old iPhone 3G");
		}
		linphone_core_enable_video_display(theLinphoneCore, FALSE);
		linphone_core_enable_video_capture(theLinphoneCore, FALSE);
	}
	
	[self enableProxyPublish:([UIApplication sharedApplication].applicationState == UIApplicationStateActive)];

	LOGI(@"Linphone [%s]  started on [%s]", linphone_core_get_version(), [[UIDevice currentDevice].model UTF8String]);

	// Post event
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore] forKey:@"core"];

	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCoreUpdate
													  object:LinphoneManager.instance
													userInfo:dict];
}

static BOOL libStarted = FALSE;

- (void)startLinphoneCore {

	if (libStarted) {
		LOGE(@"Liblinphone is already initialized!");
		return;
	}

	libStarted = TRUE;

	connectivity = none;
	signal(SIGPIPE, SIG_IGN);

	// create linphone core
	[self createLinphoneCore];
#ifndef REACHME_APP
    [self.providerDelegate config:nil];
#else
    NSString* ringTone = Constants.RINGTONE_NAME;
    if ([[ConfigurationReader sharedConfgReaderObj] isRingtoneSet])
        ringTone = @"";
    [self.providerDelegate config:ringTone];
#endif
    
	//CMP _iapManager = [[InAppProductsManager alloc] init];

	// - Security fix - remove multi transport migration, because it enables tcp or udp, if by factoring settings only
	// tls is enabled. 	This is a problem for new installations.
	// linphone_core_migrate_to_multi_transport(theLinphoneCore);

	// init audio session (just getting the instance will init)
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	BOOL bAudioInputAvailable = audioSession.inputAvailable;
	NSError *err;

	if (![audioSession setActive:NO error:&err] && err) {
		LOGE(@"audioSession setActive failed: %@", [err description]);
	}
	if (!bAudioInputAvailable) {
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No microphone", nil)
																		 message:NSLocalizedString(@"You need to plug a microphone to your device to use the application.", nil)
																  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[errView addAction:defaultAction];
		//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
	}

	// Enable notify policy for all
    /* CMP
	LinphoneImNotifPolicy *im_notif_policy;
	im_notif_policy = linphone_core_get_im_notif_policy(theLinphoneCore);
	linphone_im_notif_policy_enable_all(im_notif_policy);
    */
    
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		// go directly to bg mode
		[self enterBackgroundMode];
	}
}

void popup_link_account_cb(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status, const char *resp) {
    
    KLog1(@"Link your account name. FIXME");
    
#ifdef CMP_REMOVE
	if (status == LinphoneAccountCreatorStatusAccountLinked) {
		[LinphoneManager.instance lpConfigSetInt:0 forKey:@"must_link_account_time"];
	} else {
		LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
		if (cfg &&
			strcmp(linphone_proxy_config_get_domain(cfg),
				   [LinphoneManager.instance lpConfigStringForKey:@"domain_name"
														inSection:@"app"
													  withDefault:@"sip.linphone.org"]
					   .UTF8String) == 0) {
			UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Link your account", nil)
																			 message:[NSString stringWithFormat:NSLocalizedString(@"Link your Linphone.org account %s to your phone number.", nil),
																					  linphone_address_get_username(linphone_proxy_config_get_identity_address(cfg))]
																	  preferredStyle:UIAlertControllerStyleAlert];
			
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Maybe later", nil)
																	style:UIAlertActionStyleDefault
																  handler:^(UIAlertAction * action) {}];
			
			UIAlertAction* continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Let's go", nil)
																	 style:UIAlertActionStyleDefault
																   handler:^(UIAlertAction * action) {
																	   [PhoneMainView.instance changeCurrentView:AssistantLinkView.compositeViewDescription];
																   }];
			defaultAction.accessibilityLabel = @"Later";
			[errView addAction:defaultAction];
			[errView addAction:continueAction];
			[PhoneMainView.instance presentViewController:errView animated:YES completion:nil];

			[LinphoneManager.instance
				lpConfigSetInt:[[NSDate date] dateByAddingTimeInterval:[LinphoneManager.instance
																		   lpConfigIntForKey:@"link_account_popup_time"
																				 withDefault:84200]]
								   .timeIntervalSince1970
						forKey:@"must_link_account_time"];
		}
	}
#endif
    
}

- (void)shouldPresentLinkPopup {
	NSDate *nextTime =
		[NSDate dateWithTimeIntervalSince1970:[self lpConfigIntForKey:@"must_link_account_time" withDefault:1]];
	NSDate *now = [NSDate date];
	if (nextTime.timeIntervalSince1970 > 0 && [now earlierDate:nextTime] == nextTime) {
		LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
		if (cfg) {
			const char *username = linphone_address_get_username(linphone_proxy_config_get_identity_address(cfg));
			LinphoneAccountCreator *account_creator = linphone_account_creator_new(
				LC,
				[LinphoneManager.instance lpConfigStringForKey:@"xmlrpc_url" inSection:@"assistant" withDefault:@""]
					.UTF8String);
			linphone_account_creator_set_user_data(account_creator, (__bridge void *)(self));
			linphone_account_creator_cbs_set_is_account_linked(linphone_account_creator_get_callbacks(account_creator),
															   popup_link_account_cb);
			linphone_account_creator_set_username(account_creator, username);
			linphone_account_creator_is_account_linked(account_creator);
		}
	}
}

- (void)createLinphoneCore {
    
    KLog(@"create LinphoneCore");
    
	//CMP [self migrationAllPre];
	if (theLinphoneCore != nil) {
		LOGI(@"linphonecore is already created");
		return;
	}
	
    //CMP [Log enableLogs:[self lpConfigIntForKey:@"debugenable_preference"]];
    if([[ConfigurationReader sharedConfgReaderObj] getEnableLogFlag]) {
        [Log enableLogs:YES];
    } else {
        [Log enableLogs:NO];
    }
	connectivity = none;
    
	// Set audio assets
	NSString *ring =
		([LinphoneManager bundleFile:[self lpConfigStringForKey:@"local_ring" inSection:@"sound"].lastPathComponent]
			 ?: [LinphoneManager bundleFile:@"notes_of_the_optimistic.caf"])
			.lastPathComponent;
	NSString *ringback =
		([LinphoneManager bundleFile:[self lpConfigStringForKey:@"remote_ring" inSection:@"sound"].lastPathComponent]
			 ?: [LinphoneManager bundleFile:@"ringback.wav"])
			.lastPathComponent;
	NSString *hold =
		([LinphoneManager bundleFile:[self lpConfigStringForKey:@"hold_music" inSection:@"sound"].lastPathComponent]
			 ?: [LinphoneManager bundleFile:@"hold.mkv"])
			.lastPathComponent;
	[self lpConfigSetString:[LinphoneManager bundleFile:ring] forKey:@"local_ring" inSection:@"sound"];
	[self lpConfigSetString:[LinphoneManager bundleFile:ringback] forKey:@"remote_ring" inSection:@"sound"];
	[self lpConfigSetString:[LinphoneManager bundleFile:hold] forKey:@"hold_music" inSection:@"sound"];

	theLinphoneCore = linphone_core_new_with_config(&linphonec_vtable, _configDb, (__bridge void *)(self));
	LOGI(@"Create linphonecore %p", theLinphoneCore);

	// Load plugins if available in the linphone SDK - otherwise these calls will do nothing
    /* CMP
	MSFactory *f = linphone_core_get_ms_factory(theLinphoneCore);
	libmssilk_init(f);
	libmsamr_init(f);
	libmsx264_init(f);
	libmsopenh264_init(f);
	libmswebrtc_init(f);
	linphone_core_reload_ms_plugins(theLinphoneCore, NULL);
	[self migrationAllPost];
     */

	/* set the CA file no matter what, since the remote provisioning could be hitting an HTTPS server */
	linphone_core_set_root_ca(theLinphoneCore, [LinphoneManager bundleFile:@"rootca.pem"].UTF8String);
	linphone_core_set_user_certificates_path(theLinphoneCore, [LinphoneManager cacheDirectory].UTF8String);

	/* The core will call the linphone_iphone_configuring_status_changed callback when the remote provisioning is loaded
	 (or skipped).
	 Wait for this to finish the code configuration */

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(audioSessionInterrupted:)
											   name:AVAudioSessionInterruptionNotification
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(globalStateChangedNotificationHandler:)
											   name:kLinphoneGlobalStateUpdate
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(configuringStateChangedNotificationHandler:)
											   name:kLinphoneConfiguringStateUpdate
											 object:nil];
    /* CMP
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(inappReady:) name:kIAPReady object:nil];
     */

	/*call iterate once immediately in order to initiate background connections with sip server or remote provisioning
	 * grab, if any */
	linphone_core_iterate(theLinphoneCore);
	// start scheduler
	mIterateTimer =
		[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(iterate) userInfo:nil repeats:YES];
}

/*TODO: later -- This method is available in LinphoneCoreSettingsStore.m.
Remove this method once LinphoneCoreSettings object is made singleton.
*/
-(NSString*) getDeviceID {
    
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(!deviceID || !deviceID.length)
        deviceID = @"unknown";
    
    return deviceID;
}

- (void)destroyLinphoneCore {
    
    KLog(@"destroyLinphoneCore");
    
	[mIterateTimer invalidate];
	// just in case
	[self removeCTCallCenterCb];

	if (theLinphoneCore != nil) { // just in case application terminate before linphone core initialization
        /* CMP
		for (FileTransferDelegate *ftd in _fileTransferDelegates) {
			[ftd stopAndDestroy];
		}
		[_fileTransferDelegates removeAllObjects];
        */
        
		//linphone_core_destroy(theLinphoneCore);//Deprecated
        linphone_core_unref(theLinphoneCore);
		LOGI(@"Destroy linphonecore %p", theLinphoneCore);
		theLinphoneCore = nil;

		// Post event
		NSDictionary *dict =
			[NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore] forKey:@"core"];
		[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCoreUpdate
														  object:LinphoneManager.instance
														userInfo:dict];

		SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		if (proxyReachability)
			CFRelease(proxyReachability);
		proxyReachability = nil;
	}
	libStarted = FALSE;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetLinphoneCore {
    KLog(@"reset LinphoneCore");
    
	[self destroyLinphoneCore];
	[self createLinphoneCore];
	// reload friends
	//CMP [self.fastAddressBook reload];

	// reset network state to trigger a new network connectivity assessment
	linphone_core_set_network_reachable(theLinphoneCore, FALSE);
}

static int comp_call_id(const LinphoneCall *call, const char *callid) {
	if (linphone_call_log_get_call_id(linphone_call_get_call_log(call)) == nil) {
		ms_error("no callid for call [%p]", call);
		return 1;
	}
	return strcmp(linphone_call_log_get_call_id(linphone_call_get_call_log(call)), callid);
}

- (LinphoneCall *)callByCallId:(NSString *)call_id {
	const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
	if (!calls || !call_id) {
		return NULL;
	}
	bctbx_list_t *call_tmp = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [call_id UTF8String]);
	if (!call_tmp) {
		return NULL;
	}
	LinphoneCall *call = (LinphoneCall *)call_tmp->data;
	return call;
}

- (void)cancelLocalNotifTimerForCallId:(NSString *)callid {
	// first, make sure this callid is not already involved in a call
	const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
	bctbx_list_t *call = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String]);
	if (call != NULL) {
		LinphoneCallAppData *data =
			(__bridge LinphoneCallAppData *)(linphone_call_get_user_data((LinphoneCall *)call->data));
		if (data->timer)
			[data->timer invalidate];
		data->timer = nil;
		return;
	}
}

- (void)acceptCallForCallId:(NSString *)callid {
    
    KLog(@"acceptCallForCallId:%@",callid);
	// first, make sure this callid is not already involved in a call
	const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
	bctbx_list_t *call = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String]);
	if (call != NULL) {
        /* CMP
		const LinphoneVideoPolicy *video_policy = linphone_core_get_video_policy(theLinphoneCore);
		bool with_video = video_policy->automatically_accept;
         */
        bool with_video = false;
		[self acceptCall:(LinphoneCall *)call->data evenWithVideo:with_video];
		return;
	};
}

- (void)addPushCallId:(NSString *)callid pushPayload:(NSDictionary *)pushPayload {
    
	// first, make sure this callid is not already involved in a call
	const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
	if (bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [callid UTF8String])) {
		LOGW(@"Call id [%@] already handled", callid);
        KLog(@"Call id [%@] already handled", callid);
		return;
	};
	if ([pushCallIDs count] > 10 /*max number of pending notif*/)
		[pushCallIDs removeObjectAtIndex:0];

	[pushCallIDs addObject:callid];
}

//CMP
/*
- calledNumber will store the array of dictionaries.
- calledNumber: callId_1 = { pushPayload }, callId_2 = { pushPayload},...
*/
-(void)addToNumber:(NSString*)callId pushPayload:(NSDictionary *)pushPayload {
    
    KLog(@"addToNumber");
    /* TODO: voip_fromPhone_ prefix should be removed from the call id sent in PN.
       because, callID present in PN and SIP dialog call-id should be same.
     REMOVE the below code (which gets the correct call-id) when correct call-id is sent from the server side.
     */
    NSString* fromPhone = [pushPayload valueForKey:FROM_PHONE];
    NSString* wrongCallID = callId;
    NSString* preFix = nil;
    NSString* correctCallID = nil;
    if(fromPhone.length) {
        preFix = [NSString stringWithFormat:@"voip_%@_",fromPhone];
        NSRange replaceRange = [wrongCallID rangeOfString:preFix];
        if(replaceRange.location != NSNotFound) {
            correctCallID = [wrongCallID stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
    }
    //
    
    NSString* resultCallID = callId;
    if(correctCallID.length)
        resultCallID = correctCallID;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setObject:pushPayload forKey:resultCallID];
    if([calledNumber count] > 10)
        [calledNumber removeObjectAtIndex:0];
    
    [calledNumber addObject:dic];
    
    KLog(@"calledNumber = %@",calledNumber);
}

- (BOOL)popPushCallID:(NSString *)callId {
	for (NSString *pendingNotif in pushCallIDs) {
		if ([pendingNotif compare:callId] == NSOrderedSame) {
			[pushCallIDs removeObject:pendingNotif];
			return TRUE;
		}
	}
	return FALSE;
}

- (BOOL)resignActive {
	linphone_core_stop_dtmf_stream(theLinphoneCore);

	return YES;
}

- (void)playMessageSound {
	BOOL success = [self.messagePlayer play];
	if (!success) {
		LOGE(@"Could not play the message sound");
	}
	AudioServicesPlaySystemSound(LinphoneManager.instance.sounds.vibrate);
}

static int comp_call_state_paused(const LinphoneCall *call, const void *param) {
	return linphone_call_get_state(call) != LinphoneCallPaused;
}

- (void)startCallPausedLongRunningTask {
	pausedCallBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
	  LOGW(@"Call cannot be paused any more, too late");
	  [[UIApplication sharedApplication] endBackgroundTask:pausedCallBgTask];
	}];
	LOGI(@"Long running task started, remaining [%g s] because at least one call is paused",
		 [[UIApplication sharedApplication] backgroundTimeRemaining]);
}

- (void)startPushLongRunningTask:(BOOL)msg callId:(NSString *)callId {
	if (msg) {
		[[UIApplication sharedApplication] endBackgroundTask:pushBgTaskMsg];
		pushBgTaskMsg = 0;
		pushBgTaskMsg = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		  if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
              /* CMP
			  LOGW(@"Incomming message with call-id [%@] couldn't be received", callId);
			  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
			  content.title = NSLocalizedString(@"Message received", nil);
			  content.body = NSLocalizedString(@"You have received a message.", nil);
			  content.categoryIdentifier = @"push_msg";

			  UNNotificationRequest *req =
				  [UNNotificationRequest requestWithIdentifier:@"push_msg" content:content trigger:NULL];
			  [[UNUserNotificationCenter currentNotificationCenter]
				  addNotificationRequest:req
				   withCompletionHandler:^(NSError *_Nullable error) {
					 // Enable or disable features based on authorization.
					 if (error) {
						 LOGD(@"Error while adding notification request :");
						 LOGD(error.description);
					 }
				   }];*/
		  }
		  for (NSString *key in [LinphoneManager.instance.pushDict allKeys]) {
			  [LinphoneManager.instance.pushDict setValue:[NSNumber numberWithInt:0] forKey:key];
		  }
		  [[UIApplication sharedApplication] endBackgroundTask:pushBgTaskMsg];
		  pushBgTaskMsg = 0;
		}];
		LOGI(@"Message long running task started for call-id [%@], remaining [%g s] because a push has been received",
			 callId, [[UIApplication sharedApplication] backgroundTimeRemaining]);
	} else {
		[[UIApplication sharedApplication] endBackgroundTask:pushBgTaskCall];
		pushBgTaskCall = 0;
		pushBgTaskCall = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
          /* CMP
		  if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
			  LOGW(@"Incomming call with call-id [%@] couldn't be received", callId);
			  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
			  content.title = NSLocalizedString(@"Missed call", nil);
			  content.body = NSLocalizedString(@"You have missed a call.", nil);
			  content.categoryIdentifier = @"push_call";

			  UNNotificationRequest *req =
				  [UNNotificationRequest requestWithIdentifier:@"push_call" content:content trigger:NULL];
			  [[UNUserNotificationCenter currentNotificationCenter]
				  addNotificationRequest:req
				   withCompletionHandler:^(NSError *_Nullable error) {
					 // Enable or disable features based on authorization.
					 if (error) {
						 LOGD(@"Error while adding notification request :");
						 LOGD(error.description);
					 }
				   }];
		  }*/
            
		  for (NSString *key in [LinphoneManager.instance.pushDict allKeys]) {
			  [LinphoneManager.instance.pushDict setValue:[NSNumber numberWithInt:0] forKey:key];
		  }
		  [[UIApplication sharedApplication] endBackgroundTask:pushBgTaskCall];
		  pushBgTaskCall = 0;
		}];
		LOGI(@"Call long running task started for call-id [%@], remaining [%g s] because a push has been received",
			 callId, [[UIApplication sharedApplication] backgroundTimeRemaining]);
	}
}

- (void)enableProxyPublish:(BOOL)enabled {
	if (linphone_core_get_global_state(LC) != LinphoneGlobalOn || !linphone_core_get_default_friend_list(LC)) {
		LOGW(@"Not changing presence configuration because linphone core not ready yet");
		return;
	}	

	if ([self lpConfigBoolForKey:@"publish_presence"]) {
		// set present to "tv", because "available" does not work yet
		if (enabled) {
			linphone_core_set_presence_model(
											 LC, linphone_core_create_presence_model_with_activity(LC, LinphonePresenceActivityTV, NULL));
		}

		const MSList *proxies = linphone_core_get_proxy_config_list(LC);
		while (proxies) {
			LinphoneProxyConfig *cfg = proxies->data;
			linphone_proxy_config_edit(cfg);
			linphone_proxy_config_enable_publish(cfg, enabled);
			linphone_proxy_config_done(cfg);
			proxies = proxies->next;
		}
		// force registration update first, then update friend list subscription
		linphone_core_iterate(theLinphoneCore);
	}

    /* TODO
	const MSList *lists = linphone_core_get_friends_lists(LC);
	while (lists) {
		linphone_friend_list_enable_subscriptions(
			lists->data, enabled && [LinphoneManager.instance lpConfigBoolForKey:@"use_rls_presence"]);
		lists = lists->next;
	} */
}

- (BOOL)enterBackgroundMode {
	LinphoneProxyConfig *proxyCfg = linphone_core_get_default_proxy_config(theLinphoneCore);
	BOOL shouldEnterBgMode = FALSE;

	// disable presence
	[self enableProxyPublish:NO];
	
	// handle proxy config if any
	if (proxyCfg) {
		const char *refkey = proxyCfg ? linphone_proxy_config_get_ref_key(proxyCfg) : NULL;
		BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
		if ([LinphoneManager.instance lpConfigBoolForKey:@"backgroundmode_preference"] || pushNotifEnabled) {
			if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
				// For registration register
				[self refreshRegisters];
			}
		}

		if ([LinphoneManager.instance lpConfigBoolForKey:@"backgroundmode_preference"]) {
			// register keepalive
			if ([[UIApplication sharedApplication]
					setKeepAliveTimeout:600 /*(NSTimeInterval)linphone_proxy_config_get_expires(proxyCfg)*/
								handler:^{
								  LOGW(@"keepalive handler");
								  mLastKeepAliveDate = [NSDate date];
								  if (theLinphoneCore == nil) {
									  LOGW(@"It seems that Linphone BG mode was deactivated, just skipping");
									  return;
								  }
								  linphone_core_iterate(theLinphoneCore);
								}]) {

				LOGI(@"keepalive handler succesfully registered");
			} else {
				LOGI(@"keepalive handler cannot be registered");
			}
			shouldEnterBgMode = TRUE;
		}
	}

	LinphoneCall *currentCall = linphone_core_get_current_call(theLinphoneCore);
	const bctbx_list_t *callList = linphone_core_get_calls(theLinphoneCore);
	if (!currentCall // no active call
		&& callList  // at least one call in a non active state
		&& bctbx_list_find_custom(callList, (bctbx_compare_func)comp_call_state_paused, NULL)) {
		[self startCallPausedLongRunningTask];
	}
	if (callList) {
		/*if at least one call exist, enter normal bg mode */
		shouldEnterBgMode = TRUE;
	}
	/*stop the video preview*/
	if (theLinphoneCore) {
		linphone_core_enable_video_preview(theLinphoneCore, FALSE);
		linphone_core_iterate(theLinphoneCore);
	}
	linphone_core_stop_dtmf_stream(theLinphoneCore);

	LOGI(@"Entering [%s] bg mode", shouldEnterBgMode ? "normal" : "lite");

	if (!shouldEnterBgMode && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
		const char *refkey = proxyCfg ? linphone_proxy_config_get_ref_key(proxyCfg) : NULL;
		BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
		if (pushNotifEnabled) {
			LOGI(@"Keeping lc core to handle push");
			/*destroy voip socket if any and reset connectivity mode*/
			connectivity = none;
			linphone_core_set_network_reachable(theLinphoneCore, FALSE);
			return YES;
		}
		return NO;

	} else
		return YES;
}

- (void)becomeActive {
	// enable presence
	if (self.connectivity == none) {
		[self refreshRegisters];
	}
	if (pausedCallBgTask) {
		[[UIApplication sharedApplication] endBackgroundTask:pausedCallBgTask];
		pausedCallBgTask = 0;
	}
	if (incallBgTask) {
		[[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
		incallBgTask = 0;
	}

	/*IOS specific*/
	linphone_core_start_dtmf_stream(theLinphoneCore);
    
#ifdef CMP_REMOVE
	[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
							 completionHandler:^(BOOL granted){
							 }];
    
	/*start the video preview in case we are in the main view*/
	if (linphone_core_video_display_enabled(theLinphoneCore) && [self lpConfigBoolForKey:@"preview_preference"]) {
		linphone_core_enable_video_preview(theLinphoneCore, TRUE);
	}
#endif
    
	/*check last keepalive handler date*/
	if (mLastKeepAliveDate != Nil) {
		NSDate *current = [NSDate date];
		if ([current timeIntervalSinceDate:mLastKeepAliveDate] > 700) {
			NSString *datestr = [mLastKeepAliveDate description];
			LOGW(@"keepalive handler was called for the last time at %@", datestr);
		}
	}

	[self enableProxyPublish:YES];
}

- (void)beginInterruption {
    
    /*
    AppDelegate* appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    BOOL recordingPause=FALSE;
    int currentUiType = [appDelegate.stateMachineObj getCurrentUIType];
    if(currentUiType == INSIDE_CONVERSATION_SCREEN || currentUiType == NOTES_SCREEN || currentUiType == MY_VOBOLO_SCREEN)
    {
        BaseUI *currentUI = [appDelegate.stateMachineObj getCurrentUI];
        BaseConversationScreen  *baseConversationObj = (BaseConversationScreen *)currentUI;
        if([[baseConversationObj audioObj]isRecord])
        {
            recordingPause = TRUE;
            [baseConversationObj pauseRecording];
            [baseConversationObj hideRecordingView];
        }
        else if([[baseConversationObj audioObj]isPlay])
        {
            [baseConversationObj pausePlayingAction];
        }
    }
    else if (currentUiType == CHAT_GRID_SCREEN) {
        BaseUI *currentUI = [appDelegate.stateMachineObj getCurrentUI];
        ChatGridViewController *chatGridScreen = (ChatGridViewController*)currentUI;
        [chatGridScreen stopAudioPlayback];
        KLog(@"Chat grid screen");
    }*/
    
	LinphoneCall *c = linphone_core_get_current_call(theLinphoneCore);
	LOGI(@"Sound interruption detected!");
	if (c && linphone_call_get_state(c) == LinphoneCallStreamsRunning) {
        KLog(@"call paused");
		linphone_call_pause(c);
	}
}

- (void)endInterruption {
    
	LOGI(@"Sound interruption ended!");
    KLog(@"Sound interruption ended!");
    /*
    const MSList* c = linphone_core_get_calls(theLinphoneCore);
    if (c) {
        KLog(@"Resuming call");
        NSLog(@"Resuming call");
        linphone_call_resume((LinphoneCall*)c);
    }*/
}

- (void)refreshRegisters {
    KLog(@"refreshRegisters");
	if (connectivity == none) {
		// don't trust ios when he says there is no network. Create a new reachability context, the previous one might
		// be mis-functionning.
        LOGI(@"None connectivity");
        KLog(@"None connectivity");
		[self setupNetworkReachabilityCallback];
	}
    LOGI(@"Network reachability callback setup");
    linphone_core_refresh_registers(theLinphoneCore); // just to make sure REGISTRATION is up to date
}

/* CMP
- (void)renameDefaultSettings {
	// rename .linphonerc to linphonerc to ease debugging: when downloading
	// containers from MacOSX, Finder do not display hidden files leading
	// to useless painful operations to display the .linphonerc file
	NSString *src = [LinphoneManager documentFile:@".linphonerc"];
	NSString *dst = [LinphoneManager documentFile:@"linphonerc"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *fileError = nil;
	if ([fileManager fileExistsAtPath:src]) {
		if ([fileManager fileExistsAtPath:dst]) {
			[fileManager removeItemAtPath:src error:&fileError];
			LOGW(@"%@ already exists, simply removing %@ %@", dst, src,
				 fileError ? fileError.localizedDescription : @"successfully");
		} else {
			[fileManager moveItemAtPath:src toPath:dst error:&fileError];
			LOGI(@"%@ moving to %@ %@", dst, src, fileError ? fileError.localizedDescription : @"successfully");
		}
	}
}
 */

- (void)copyDefaultSettings {
	NSString *src = [LinphoneManager bundleFile:@"linphonerc"];
	NSString *srcIpad = [LinphoneManager bundleFile:@"linphonerc~ipad"];
	if (IPAD && [[NSFileManager defaultManager] fileExistsAtPath:srcIpad]) {
		src = srcIpad;
	}
	NSString *dst = [LinphoneManager documentFile:@"linphonerc"];
	[LinphoneManager copyFile:src destination:dst override:FALSE];
}

- (void)overrideDefaultSettings {
	NSString *factory = [LinphoneManager bundleFile:@"linphonerc-factory"];
	NSString *factoryIpad = [LinphoneManager bundleFile:@"linphonerc-factory~ipad"];
	if (IPAD && [[NSFileManager defaultManager] fileExistsAtPath:factoryIpad]) {
		factory = factoryIpad;
	}
	NSString *confiFileName = [LinphoneManager documentFile:@"linphonerc"];
	_configDb = lp_config_new_with_factory([confiFileName UTF8String], [factory UTF8String]);
}

#pragma mark - Audio route Functions

- (bool)allowSpeaker {
	if (IPAD)
		return true;

	bool allow = true;
	AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;
	if (newRoute) {
		NSString *route = newRoute.outputs[0].portType;
		allow = !([route isEqualToString:AVAudioSessionPortLineOut] ||
				  [route isEqualToString:AVAudioSessionPortHeadphones] ||
				  [[AudioHelper bluetoothRoutes] containsObject:route]);
	}
	return allow;
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
	if (IPAD)
		return;

	// there is at least one bug when you disconnect an audio bluetooth headset
	// since we only get notification of route having changed, we cannot tell if that is due to:
	// -bluetooth headset disconnected or
	// -user wanted to use earpiece
	// the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
	if ([[notif.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue] ==
		AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
		_bluetoothAvailable = NO;
	}
	AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;

	if (newRoute.outputs.count) {
		NSString *route = newRoute.outputs[0].portType;
		LOGI(@"Current audio route is [%s]", [route UTF8String]);

		_speakerEnabled = [route isEqualToString:AVAudioSessionPortBuiltInSpeaker];
		if (([[AudioHelper bluetoothRoutes] containsObject:route]) && !_speakerEnabled) {
			_bluetoothAvailable = TRUE;
			_bluetoothEnabled = TRUE;
		} else {
			_bluetoothEnabled = FALSE;
		}
		NSDictionary *dict = [NSDictionary
			dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:_bluetoothAvailable], @"available", nil];
		[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneBluetoothAvailabilityUpdate
														  object:self
														userInfo:dict];
    } else {
        KLog(@"newRoute  = %@", newRoute);
    }
}

- (void)setSpeakerEnabled:(BOOL)enable {
    
    KLog(@"setSpeakerEnabled:%d",enable);
    
	_speakerEnabled = enable;
	NSError *err;

	if (enable && [self allowSpeaker]) {
		[[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
		_bluetoothEnabled = FALSE;
	} else {
		AVAudioSessionPortDescription *builtinPort = [AudioHelper builtinAudioDevice];
		[[AVAudioSession sharedInstance] setPreferredInput:builtinPort error:&err];
	}

	if (err) {
		LOGE(@"Failed to change audio route: err %@", err.localizedDescription);
	}
}

- (void)setBluetoothEnabled:(BOOL)enable {
	if (_bluetoothAvailable) {
		// The change of route will be done in setSpeakerEnabled
		_bluetoothEnabled = enable;
		if (_bluetoothEnabled) {
			NSError *err;
			AVAudioSessionPortDescription *_bluetoothPort = [AudioHelper bluetoothAudioDevice];
			[[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort error:&err];
			// if setting bluetooth failed, it must be because the device is not available
			// anymore (disconnected), so deactivate bluetooth.
			if (err) {
				_bluetoothEnabled = FALSE;
			} else {
				_speakerEnabled = FALSE;
				return;
			}
		}
	}
	[self setSpeakerEnabled:_speakerEnabled];
}

#pragma mark - Call Functions

- (void)acceptCall:(LinphoneCall *)call evenWithVideo:(BOOL)video {
	LinphoneCallParams *lcallParams = linphone_core_create_call_params(theLinphoneCore, call);
	if (!lcallParams) {
		LOGW(@"Could not create call parameters for %p, call has probably already ended.", call);
		return;
	}

	if ([self lpConfigBoolForKey:@"edge_opt_preference"]) {
		bool low_bandwidth = self.network == network_2g;
		if (low_bandwidth) {
			LOGI(@"Low bandwidth mode");
		}
		linphone_call_params_enable_low_bandwidth(lcallParams, low_bandwidth);
	}
	linphone_call_params_enable_video(lcallParams, video);

    
    //- Add custom header "DeviceID"
    SettingModelMqtt* mqttSetting = [[[Setting sharedSetting]data]mqttSetting];
    NSString* deviceID = [mqttSetting.deviceId stringValue];
    if(deviceID && deviceID.length) {
        linphone_call_params_add_custom_header(lcallParams, kCustomHdrDeviceId.UTF8String, deviceID.UTF8String);
    }
    
	linphone_call_accept_with_params(call, lcallParams);
}


-(void)initiateOBDCall:(NSString*)toNumber FromNumber:(NSString *)fromNumber WithCallType:(NSString *)callType {
    
    //NSString* loggedInNum = [[ConfigurationReader sharedConfgReaderObj]getLoginId];
    
    self.callType = callType;
    _fromNumber = fromNumber;
    
    if ([toNumber length] > 0) {
        LinphoneAddress *addr = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore] normalizePhoneAddress:toNumber];
        [self call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }
}

-(void)inviteNewUser {
    if(callOptionsController) {
        [callOptionsController dismissViewControllerAnimated:YES completion:nil];
        callOptionsController = nil;
    }
    NSArray *items = @[NSLocalizedString(@"SMS_MESSAGE_PHONE", nil)];
    UIActivityViewController* activityVC =[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,
                                            BOOL completed,
                                            NSArray *returnedItems,
                                            NSError *error){
        if (error) {
            KLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
    AppDelegate* appDelegate = (AppDelegate *)APP_DELEGATE;
    [appDelegate.getNavController presentViewController:activityVC animated:YES completion:nil];
}

- (void)call:(const LinphoneAddress *)iaddr  {
    
	// First verify that network is available, abort otherwise.
	if (!linphone_core_is_network_reachable(theLinphoneCore)) {
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Network Error", nil)
																		 message:NSLocalizedString(@"There is no network connection available, enable WIFI or WWAN prior to place a call", nil)
																  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[errView addAction:defaultAction];
        //CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:errView animated:YES completion:nil];
		return;
	}

	// Then check that no GSM calls are in progress, abort otherwise.
	CTCallCenter *callCenter = [[CTCallCenter alloc] init];
	if ([callCenter currentCalls] != nil && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
		LOGE(@"GSM call in progress, cancelling outgoing SIP call request");
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cannot make call", nil)
																		 message:NSLocalizedString(@"Please terminate GSM call first.", nil)
																  preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];

		[errView addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:errView animated:YES completion:nil];
		//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
		return;
	}

	// Then check that the supplied address is valid
	if (!iaddr) {
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid SIP address", nil)
																		 message:NSLocalizedString(@"Either configure a SIP proxy server from settings prior to place a "
																								   @"call or use a valid SIP address (I.E sip:john@example.net)", nil)
																  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[errView addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:errView animated:YES completion:nil];
		//CMP [PhoneMainView.instance presentViewController:errView animated:YES completion:nil];
		return;
	}
    
    KLog(@"self.providerDelegate.callKitCalls: %d",self.providerDelegate.callKitCalls);
    KLog(@"linphone_core_get_calls_nb(theLinphoneCore): %d",linphone_core_get_calls_nb(theLinphoneCore));
	if (linphone_core_get_calls_nb(theLinphoneCore) < 1 &&
		floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max &&
		self.providerDelegate.callKitCalls < 1) {
       
		self.providerDelegate.callKitCalls++;
		NSUUID *uuid = [NSUUID UUID];
		[LinphoneManager.instance.providerDelegate.uuids setObject:uuid forKey:@""];
		[LinphoneManager.instance.providerDelegate.calls setObject:@"" forKey:uuid];
		LinphoneManager.instance.providerDelegate.pendingAddr = linphone_address_clone(iaddr);
		//CMP NSString *address = [FastAddressBook displayNameForAddress:iaddr];
        NSString* toPhoneNumber = [self displayNameForAddress:iaddr];
        //NSString* contactName = [self getContactName:toPhoneNumber];
        
        //APR 17, 2018
        //NSString* fromNumber = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore]myPrimaryNumber];
        [LinphoneManager.instance.providerDelegate makeCall:toPhoneNumber FromNumber:_fromNumber];
        
        KLog(@"request startCallAction");
		CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:toPhoneNumber];
		CXStartCallAction *act = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
		CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
		[LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
																	  completion:^(NSError *err){
																	  }];
	} else {
		[self doCall:iaddr];
	}
}



- (BOOL)doCall:(const LinphoneAddress *)iaddr {
    
    KLog(@"doCall");
    
	LinphoneAddress *addr = linphone_address_clone(iaddr);
	NSString* temp = [self displayNameForAddress:addr];
    NSString* displayName = [self getContactName:temp];

	// Finally we can make the call
	LinphoneCallParams *lcallParams = linphone_core_create_call_params(theLinphoneCore, NULL);
	if ([self lpConfigBoolForKey:@"edge_opt_preference"] && (self.network == network_2g)) {
		LOGI(@"Enabling low bandwidth mode");
		linphone_call_params_enable_low_bandwidth(lcallParams, YES);
	}

	if (displayName != nil) {
		linphone_address_set_display_name(addr, displayName.UTF8String);
	}
	if ([LinphoneManager.instance lpConfigBoolForKey:@"override_domain_with_default_one"]) {
		linphone_address_set_domain(
			addr, [[LinphoneManager.instance lpConfigStringForKey:@"domain" inSection:@"assistant"] UTF8String]);
	}

	LinphoneCall *call;
	if (LinphoneManager.instance.nextCallIsTransfer) {
		char *caddr = linphone_address_as_string(addr);
		call = linphone_core_get_current_call(theLinphoneCore);
		linphone_call_transfer(call, caddr);
		LinphoneManager.instance.nextCallIsTransfer = NO;
		ms_free(caddr);
	} else {
        //CMP
        linphone_call_params_add_custom_header(lcallParams, kCustomHdrOBD.UTF8String, [self getObdHeaderValue].UTF8String);
        //
		call = linphone_core_invite_address_with_params(theLinphoneCore, addr, lcallParams);
		if (call) {
			// The LinphoneCallAppData object should be set on call creation with callback
			// - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
			// We are NOT responsible for creating the AppData.
			LinphoneCallAppData *data = (__bridge LinphoneCallAppData *)linphone_call_get_user_data(call);
			if (data == nil) {
				LOGE(@"New call instanciated but app data was not set. Expect it to crash.");
				/* will be used later to notify user if video was not activated because of the linphone core*/
			} else {
				data->videoRequested = linphone_call_params_video_enabled(lcallParams);
			}
		}
	}
	//CMP linphone_address_destroy(addr);
    linphone_address_unref(addr);
	//CMP linphone_call_params_destroy(lcallParams);
    linphone_call_params_unref(lcallParams);

	return TRUE;
}

-(BOOL)isNumber:(NSString*)text
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber* number = [numberFormatter numberFromString:text];
    
    if (number != nil)
        return TRUE;
    
    return FALSE;
}

-(void)makeCall:(NSString*)address
    FromAddress:(NSString*)fromAddress
       UserType:(NSString *)userType
     CalleeInfo:(NSDictionary *)info
{
    
    if(!address.length) {
        //TODO display an appropriate warning dialog to the user and return
        KLog(@"Invalid number");
    }
    
    if( ![self isNumber:address]) {
        EnLogd(@"ToAddress is not a phone number.");
        //[ScreenUtility showAlert:@"Not a valid phone number"];
        return;
    }

    if ([address isEqualToString:[[ConfigurationReader sharedConfgReaderObj] getLoginId]])
    {
        [ScreenUtility showAlert:@"Cannot call to your own number"];
        return;
    }
    
    NSString* remoteUserType = userType;
    
    //- Get primary and additional numbers
    NSString* fromNumber = @"";
    if(!fromAddress || !fromAddress.length)
        fromNumber = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore]myPrimaryNumber];
    else
        fromNumber = fromAddress;
    
    UserProfileModel* currentUserProfileDetails = [Profile sharedUserProfile].profileData;
    NSMutableArray* additionalLinkedVerifiedNumbers = currentUserProfileDetails.additionalVerifiedNumbers;
    NSMutableArray* linkedMobileNumbers = [[NSMutableArray alloc]init];
    [linkedMobileNumbers addObjectsFromArray:[additionalLinkedVerifiedNumbers valueForKeyPath:@"contact_id"]];
    [linkedMobileNumbers removeObject:fromNumber];
    [linkedMobileNumbers insertObject:fromNumber atIndex:0];
    
    
    //- format the primary number and additional numbers
    NSMutableArray* formattedLinkedNumbers = [[NSMutableArray alloc]init];
    for(NSString* phnum in linkedMobileNumbers) {
        NSString* formattedFromNumber = [Common getFormattedNumber:phnum withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(formattedFromNumber && formattedFromNumber.length) {
            [formattedLinkedNumbers addObject:formattedFromNumber];
        } else {
            [formattedLinkedNumbers addObject:phnum];
        }
    }
    
    NSMutableArray* toNumbers = [[NSMutableArray alloc]initWithObjects:address, nil];
    callOptionsController = [UIAlertController alertControllerWithTitle:@""
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    //
    //- Get callee's additional numbers and profile pic
    ContactDetailData* detailDataContact = nil;
    NSArray* contactDetailList = [[Contacts sharedContact]getContactForPhoneNumber:address];
    if([contactDetailList count] > 0)
    {
        EnLogd(@"Contact details:%@,%@",address,contactDetailList);
        ContactDetailData* detail = [contactDetailList objectAtIndex:0];
        ContactData* data = detail.contactIdParentRelation;
        NSSet* all = data.contactIdDetailRelation;
        for(ContactDetailData* obj in all)
        {
            NSString* dataValue =  obj.contactDataValue;
            if(dataValue && [obj.contactDataType isEqualToString:PHONE_MODE]) {
                if([dataValue isEqualToString:address])
                    detailDataContact = obj;
                else
                    [toNumbers addObject:dataValue];
            }
        }
    } else {
        EnLogd(@"Contact details not found: %@",address);
    }
    
    //- format the callee's numbers
    NSMutableArray* formattedToNumbers = [[NSMutableArray alloc]init];
    for(NSString* phnum in toNumbers) {
        NSString* formattedToNumber = [Common getFormattedNumber:phnum withCountryIsdCode:nil withGivenNumberisCannonical:YES];
        if(formattedToNumber && formattedToNumber.length) {
            [formattedToNumbers addObject:formattedToNumber];
        } else {
            [formattedToNumbers addObject:phnum];
        }
    }
    
    //- Get the callee's profile pic
    NSString* remoteContactPic = @"";
    NSString* calleeName = @"";
    if(detailDataContact) {
        remoteContactPic = [IVFileLocator getNativeContactPicPath:detailDataContact.contactIdParentRelation.contactPic];
        calleeName = detailDataContact.contactIdParentRelation.contactName;
        if(!remoteUserType || !remoteUserType.length) {
            EnLogd(@"Contact: %@", detailDataContact.contactIdParentRelation);
            if([detailDataContact.contactIdParentRelation.isIV boolValue])
                remoteUserType = IV_TYPE;
            else
                remoteUserType = @"tel";
        }
    }
    //-
    
    EnLogd(@"remoteUserType:%d",remoteUserType);
    //- create CustomCallViewController and pass From and To numbers
    CustomCallViewController* customVc = [[CustomCallViewController alloc] initWithNibName:@"CustomCallViewController" bundle:nil];
    [customVc setArrFromNumbers:formattedLinkedNumbers];
    [customVc setArrToNumbers:formattedToNumbers];
    [customVc setCalleeProfilePicPath:remoteContactPic];
    [customVc setCalleeName:calleeName];
    if([remoteUserType isEqualToString:IV_TYPE])
        [customVc setIsCalleeIVUser:YES];
    else
        [customVc setIsCalleeIVUser:NO];
    
    //if(info.count)
    {
        [customVc setCalleeInfo:info];
    }
    
    customVc.preferredContentSize = CGSizeMake(callOptionsController.view.bounds.size.width - 8.0 * 4.0F, 310.0F);
    [callOptionsController setValue:customVc forKey:@"contentViewController"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {}];
    
    [callOptionsController addAction:cancelAction];
    AppDelegate* appDelegateCall = (AppDelegate *)APP_DELEGATE;
    [appDelegateCall.tabBarController presentViewController:callOptionsController animated:YES completion:nil];
    
    KLog(@"Done");
}


/*
 Returns a string with <natTpe, CallType, FromNumber>
 natType = symm, nonsymm, unknown
 CallType = p2p, gsm
 FromNumber = PrimaryNumber
 
 Note:
 For nonSymm NAT type, INVITE SDP should contain public IP.
 For symm NAT type, INVITE SDP should contain private IP.
 */
-(NSString*)getObdHeaderValue {
    
    NSString* natType = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore]getNatType];
    //NSString* fromNumber = [[LinphoneCoreSettingsStore sharedLinphoneCoreSettingsStore]myPrimaryNumber];
    NSString* ret = [NSString stringWithFormat:@"%@,%@,%@",natType,self.callType,_fromNumber];
    KLog(@"header value:%@",ret);
    return ret;
}

-(NSString*)displayNameForAddress:(const LinphoneAddress*) addr {
    
    NSString *ret = NSLocalizedString(@"Unknown", nil);
    const char *lDisplayName = linphone_address_get_display_name(addr);
    const char *lUserName = linphone_address_get_username(addr);
    if (lDisplayName) {
        ret = [NSString stringWithUTF8String:lDisplayName];
    } else if (lUserName) {
        ret = [NSString stringWithUTF8String:lUserName];
    }
    
    return ret;
}

-(NSString*)getUserNameFromAddress:(const LinphoneAddress*) addr {
    
    NSString *ret = NSLocalizedString(@"Unknown", nil);
    const char *lUserName = linphone_address_get_username(addr);
    if (lUserName) {
        ret = [NSString stringWithUTF8String:lUserName];
    }
    
    return ret;
}

-(NSString*)getContactName:(NSString*)phoneNumber {
    
    NSString* callerName = @"";
    NSString* finalHandle = phoneNumber;
    NSString* fName = [Common getFormattedNumber:phoneNumber withCountryIsdCode:nil withGivenNumberisCannonical:YES];
    if(fName && fName.length) {
        finalHandle = fName;
        NSString* name = [LinphoneManager.instance.providerDelegate getIVUserNameFromPhoneNumber:phoneNumber];
        if(name.length)
            callerName = name;
    } else {
        //- should not happen; fName may not be number or getFormattedNumber failed to format the number
        //callerName = handle;
    }
    
    if(callerName.length)
        return callerName;
    
    return finalHandle;
}


-(NSString*)getToNumberForCallId:(NSString *)callId {
    
    for(NSDictionary* dic in calledNumber) {
        NSDictionary* aps = [dic objectForKey:callId];
        if(aps) {
            NSString* toNumber = [aps valueForKey:@"to_phone"];
            if(toNumber.length)
                return toNumber;
        }
    }
    
    return @"";
}

-(NSMutableDictionary*)getPushDictionary:(NSString*)callId {
    
    KLog(@"callId = %@",callId);
    
    NSString* newCallId=@"";
    /* callId from PN is last 3 chars truncated. TODO: TO BE FIXED in Kamailio*/
    if(callId.length>3)
        newCallId = [callId substringToIndex:callId.length-3];
    //
    
    for(NSDictionary* dic in calledNumber) {
        NSMutableDictionary* aps = [dic objectForKey:callId];
        if(aps)
            return aps;
        //TODO: remove
        else {
            if(newCallId) {
                aps = [dic objectForKey:newCallId];
                if(aps)
                    return aps;
            }
        }//
    }
    return nil;
}

#pragma mark - Property Functions

- (void)setPushNotificationToken:(NSData *)apushNotificationToken {
	if (apushNotificationToken == _pushNotificationToken) {
		return;
	}
	_pushNotificationToken = apushNotificationToken;

	@try {
		const MSList *proxies = linphone_core_get_proxy_config_list(LC);
		while (proxies) {
			[self configurePushTokenForProxyConfig:proxies->data];
			proxies = proxies->next;
		}
	} @catch (NSException* e) {
		LOGW(@"%s: linphone core not ready yet, ignoring push token", __FUNCTION__);
	}
}

-(BOOL)isVoipCallBlocked:(NSString*)theNumber {
    
    return ([self.voipCallBlockedContacts containsObject:theNumber]);
}

- (void)configurePushTokenForProxyConfig:(LinphoneProxyConfig *)proxyCfg {
	linphone_proxy_config_edit(proxyCfg);

	NSData *tokenData = _pushNotificationToken;
	const char *refkey = linphone_proxy_config_get_ref_key(proxyCfg);
	BOOL pushNotifEnabled = (refkey && strcmp(refkey, "push_notification") == 0);
	if (tokenData != nil && pushNotifEnabled) {
		const unsigned char *tokenBuffer = [tokenData bytes];
		NSMutableString *tokenString = [NSMutableString stringWithCapacity:[tokenData length] * 2];
		for (int i = 0; i < [tokenData length]; ++i) {
			[tokenString appendFormat:@"%02X", (unsigned int)tokenBuffer[i]];
		}
// NSLocalizedString(@"IC_MSG", nil); // Fake for genstrings
// NSLocalizedString(@"IM_MSG", nil); // Fake for genstrings
// NSLocalizedString(@"IM_FULLMSG", nil); // Fake for genstrings
#ifdef DEBUG
#define APPMODE_SUFFIX @"dev"
#else
#define APPMODE_SUFFIX @"prod"
#endif
		NSString *ring =
		([LinphoneManager bundleFile:[self lpConfigStringForKey:@"local_ring" inSection:@"sound"].lastPathComponent]
		 ?: [LinphoneManager bundleFile:@"notes_of_the_optimistic.caf"])
		.lastPathComponent;
        NSString * notif_type;
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
            //IOS 8 and more
            notif_type = @".voip";
        } else {
            // IOS 7 and below
            notif_type = @"";
        }
        NSString *timeout;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            timeout = @";pn-timeout=0";
        } else {
            timeout = @"";
        }
		
		NSString *silent;
		if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
			silent = @";pn-silent=1";
		} else {
			silent = @"";
		}
		
		NSString *params = [NSString
			stringWithFormat:@"app-id=%@%@.%@;pn-type=apple;pn-tok=%@;pn-msg-str=IM_MSG;pn-call-str=IC_MSG;pn-"
							 @"call-snd=%@;pn-msg-snd=msg.caf%@%@",
							 [[NSBundle mainBundle] bundleIdentifier], notif_type, APPMODE_SUFFIX, tokenString, ring, timeout, silent];

		LOGI(@"Proxy config %s configured for push notifications with contact: %@",
			 linphone_proxy_config_get_identity(proxyCfg), params);
		linphone_proxy_config_set_contact_uri_parameters(proxyCfg, [params UTF8String]);
		linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
	} else {
		LOGI(@"Proxy config %s NOT configured for push notifications", linphone_proxy_config_get_identity(proxyCfg));
		// no push token:
		linphone_proxy_config_set_contact_uri_parameters(proxyCfg, NULL);
		linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
	}

	linphone_proxy_config_done(proxyCfg);
}

#pragma mark - Misc Functions

+ (NSString *)bundleFile:(NSString *)file {
	return [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
}

+ (NSString *)documentFile:(NSString *)file {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	return [documentsPath stringByAppendingPathComponent:file];
}

+ (NSString *)cacheDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachePath = [paths objectAtIndex:0];
	BOOL isDir = NO;
	NSError *error;
	// cache directory must be created if not existing
	if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath
								  withIntermediateDirectories:NO
												   attributes:nil
														error:&error];
	}
	return cachePath;
}

+ (int)unreadMessageCount {
	int count = 0;
	const MSList *rooms = linphone_core_get_chat_rooms(LC);
	const MSList *item = rooms;
	while (item) {
		LinphoneChatRoom *room = (LinphoneChatRoom *)item->data;
		if (room) {
			count += linphone_chat_room_get_unread_messages_count(room);
		}
		item = item->next;
	}

	return count;
}

+ (BOOL)copyFile:(NSString *)src destination:(NSString *)dst override:(BOOL)override {
	NSFileManager *fileManager = NSFileManager.defaultManager;
	NSError *error = nil;
	if ([fileManager fileExistsAtPath:src] == NO) {
		LOGE(@"Can't find \"%@\": %@", src, [error localizedDescription]);
		return FALSE;
	}
	if ([fileManager fileExistsAtPath:dst] == YES) {
		if (override) {
			[fileManager removeItemAtPath:dst error:&error];
			if (error != nil) {
				LOGE(@"Can't remove \"%@\": %@", dst, [error localizedDescription]);
				return FALSE;
			}
		} else {
			LOGW(@"\"%@\" already exists", dst);
			return FALSE;
		}
	}
	[fileManager copyItemAtPath:src toPath:dst error:&error];
	if (error != nil) {
		LOGE(@"Can't copy \"%@\" to \"%@\": %@", src, dst, [error localizedDescription]);
		return FALSE;
	}
	return TRUE;
}

- (void)configureVbrCodecs {
	PayloadType *pt;
	int bitrate = lp_config_get_int(
		_configDb, "audio", "codec_bitrate_limit",
		kLinphoneAudioVbrCodecDefaultBitrate); /*default value is in linphonerc or linphonerc-factory*/
	const MSList *audio_codecs = linphone_core_get_audio_codecs(theLinphoneCore);
	const MSList *codec = audio_codecs;
	while (codec) {
		pt = codec->data;
		if (linphone_core_payload_type_is_vbr(theLinphoneCore, pt)) {
			linphone_core_set_payload_type_bitrate(theLinphoneCore, pt, bitrate);
		}
		codec = codec->next;
	}
}

+ (id)getMessageAppDataForKey:(NSString *)key inMessage:(LinphoneChatMessage *)msg {

	if (msg == nil)
		return nil;

	id value = nil;
	const char *appData = linphone_chat_message_get_appdata(msg);
	if (appData) {
		NSDictionary *appDataDict =
			[NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)]
											options:0
											  error:nil];
		value = [appDataDict objectForKey:key];
	}
	return value;
}

+ (void)setValueInMessageAppData:(id)value forKey:(NSString *)key inMessage:(LinphoneChatMessage *)msg {

	NSMutableDictionary *appDataDict = [NSMutableDictionary dictionary];
	const char *appData = linphone_chat_message_get_appdata(msg);
	if (appData) {
		appDataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)]
													  options:NSJSONReadingMutableContainers
														error:nil];
	}

	[appDataDict setValue:value forKey:key];

	NSData *data = [NSJSONSerialization dataWithJSONObject:appDataDict options:0 error:nil];
	NSString *appdataJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	linphone_chat_message_set_appdata(msg, [appdataJSON UTF8String]);
}

#pragma mark - LPConfig Functions

- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key {
	[self lpConfigSetString:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section {
	if (!key)
		return;
	lp_config_set_string(_configDb, [section UTF8String], [key UTF8String], value ? [value UTF8String] : NULL);
}
- (NSString *)lpConfigStringForKey:(NSString *)key {
	return [self lpConfigStringForKey:key withDefault:nil];
}
- (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)defaultValue {
	return [self lpConfigStringForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section {
	return [self lpConfigStringForKey:key inSection:section withDefault:nil];
}
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)defaultValue {
	if (!key)
		return defaultValue;
	const char *value = lp_config_get_string(_configDb, [section UTF8String], [key UTF8String], NULL);
	return value ? [NSString stringWithUTF8String:value] : defaultValue;
}

- (void)lpConfigSetInt:(int)value forKey:(NSString *)key {
	[self lpConfigSetInt:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section {
	if (!key)
		return;
	lp_config_set_int(_configDb, [section UTF8String], [key UTF8String], (int)value);
}
- (int)lpConfigIntForKey:(NSString *)key {
	return [self lpConfigIntForKey:key withDefault:-1];
}
- (int)lpConfigIntForKey:(NSString *)key withDefault:(int)defaultValue {
	return [self lpConfigIntForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section {
	return [self lpConfigIntForKey:key inSection:section withDefault:-1];
}
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)defaultValue {
	if (!key)
		return defaultValue;
	return lp_config_get_int(_configDb, [section UTF8String], [key UTF8String], (int)defaultValue);
}

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key {
	[self lpConfigSetBool:value forKey:key inSection:LINPHONERC_APPLICATION_KEY];
}
- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section {
	[self lpConfigSetInt:(int)(value == TRUE) forKey:key inSection:section];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key {
	return [self lpConfigBoolForKey:key withDefault:FALSE];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)defaultValue {
	return [self lpConfigBoolForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section {
	return [self lpConfigBoolForKey:key inSection:section withDefault:FALSE];
}
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)defaultValue {
	if (!key)
		return defaultValue;
	int val = [self lpConfigIntForKey:key inSection:section withDefault:-1];
	return (val != -1) ? (val == 1) : defaultValue;
}

#pragma mark - GSM management

- (void)removeCTCallCenterCb {
	if (mCallCenter != nil) {
		LOGI(@"Removing CT call center listener [%p]", mCallCenter);
		mCallCenter.callEventHandler = NULL;
	}
	mCallCenter = nil;
}

- (void)setupGSMInteraction {

	[self removeCTCallCenterCb];
	mCallCenter = [[CTCallCenter alloc] init];
	LOGI(@"Adding CT call center listener [%p]", mCallCenter);
	__block __weak LinphoneManager *weakSelf = self;
	__block __weak CTCallCenter *weakCCenter = mCallCenter;
	mCallCenter.callEventHandler = ^(CTCall *call) {
	  // post on main thread
	  [weakSelf performSelectorOnMainThread:@selector(handleGSMCallInteration:)
								 withObject:weakCCenter
							  waitUntilDone:YES];
	};
}

- (void)handleGSMCallInteration:(id)cCenter {
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
		CTCallCenter *ct = (CTCallCenter *)cCenter;
		// pause current call, if any
		LinphoneCall *call = linphone_core_get_current_call(theLinphoneCore);
		if ([ct currentCalls] != nil) {
			if (call) {
				LOGI(@"Pausing SIP call because GSM call");
				linphone_call_pause(call);
				[self startCallPausedLongRunningTask];
			} else if (linphone_core_is_in_conference(theLinphoneCore)) {
				LOGI(@"Leaving conference call because GSM call");
				linphone_core_leave_conference(theLinphoneCore);
				[self startCallPausedLongRunningTask];
			}
		} // else nop, keep call in paused state
	}
}

- (NSString *)contactFilter {
	NSString *filter = @"*";
	if ([self lpConfigBoolForKey:@"contact_filter_on_default_domain"]) {
		LinphoneProxyConfig *proxy_cfg = linphone_core_get_default_proxy_config(theLinphoneCore);
		if (proxy_cfg && linphone_proxy_config_get_addr(proxy_cfg)) {
			return [NSString stringWithCString:linphone_proxy_config_get_domain(proxy_cfg)
									  encoding:[NSString defaultCStringEncoding]];
		}
	}
	return filter;
}

#pragma mark - InApp Purchase events

- (void)inappReady:(NSNotification *)notif {
	// Query our in-app server to retrieve InApp purchases
	//[_iapManager retrievePurchases];
}

#pragma mark -

- (void)removeAllAccounts {
	linphone_core_clear_proxy_config(LC);
	linphone_core_clear_all_auth_info(LC);
}

+ (BOOL)isMyself:(const LinphoneAddress *)addr {
	if (!addr)
		return NO;

	const MSList *it = linphone_core_get_proxy_config_list(LC);
	while (it) {
		if (linphone_address_weak_equal(addr, linphone_proxy_config_get_identity_address(it->data))) {
			return YES;
		}
		it = it->next;
	}
	return NO;
}

// ugly hack to export symbol from liblinphone so that they are available for the linphoneTests target
// linphoneTests target do not link with liblinphone but instead dynamically link with ourself which is
// statically linked with liblinphone, so we must have exported required symbols from the library to
// have them available in linphoneTests
// DO NOT INVOKE THIS METHOD
- (void)exportSymbolsForUITests {
	linphone_address_set_header(NULL, NULL, NULL);
}


/*
 BW Usage: download BW(kbits/s), upload BW (kbits/s), sender loss rate, receiver loss rate, cumulative number of late packets,
 sender interarrival jitter, receiver interarrival jitter, jitter buffer size (in ms), roundtrip delay(in sec), call quality
 */
-(void) callStatsUpdate {
    
    if(!thisCallLog)
        return;
    
    NSString* callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(thisCallLog)];
    if(!callId.length)
        return;
    
    LinphoneCall* call = [LinphoneManager.instance callByCallId:callId];
    if(!call) {
        KLog(@"No Call object. return");
        return;
    }
    
    LinphoneCallStats* callStats = linphone_call_get_stats(call, LinphoneStreamTypeAudio);
    
    float downloadBW = linphone_call_stats_get_download_bandwidth(callStats);
    float uploadBW = linphone_call_stats_get_upload_bandwidth(callStats);
    float senderLossRate = linphone_call_stats_get_sender_loss_rate(callStats);
    float recvrLossRate = linphone_call_stats_get_receiver_loss_rate(callStats);
    uint64_t cumLatePackets = linphone_call_stats_get_late_packets_cumulative_number(callStats);
    float senderInterArrivalJitter = linphone_call_stats_get_sender_interarrival_jitter(callStats);
    float recvrInterArrivalJitter = linphone_call_stats_get_receiver_interarrival_jitter(callStats);
    float jitterBufSize = linphone_call_stats_get_jitter_buffer_size_ms(callStats);
    float rtdelay = linphone_call_stats_get_round_trip_delay(callStats); //in seconds
    float callQuality = linphone_call_get_current_quality(call);
   
    if(!codec.length) {
        const LinphoneCallParams* callParams = linphone_call_get_current_params(call);
        const OrtpPayloadType* pt = linphone_call_params_get_used_audio_codec(callParams);
        
        //LinphonePayloadType* pt1 =  linphone_call_params_get_used_audio_payload_type(callParams);
        //int normalBitRate = linphone_payload_type_get_normal_bitrate(pt1);
        
        const char* mime = payload_type_get_mime(pt);
        codec = [NSString stringWithUTF8String:mime];
        bitRate = payload_type_get_bitrate(pt);
        clockRate = payload_type_get_rate(pt);
    }
    
    if(!bwUsage)
        bwUsage = @"";
    
    bwUsage = [bwUsage stringByAppendingFormat:@"%.1f,%.1f,%.1f,%.1f,%llu,%.1f,%.1f,%.1f,%.1f,%.1f\n",
               downloadBW, uploadBW, senderLossRate, recvrLossRate, cumLatePackets, senderInterArrivalJitter, recvrInterArrivalJitter,
               jitterBufSize, rtdelay, callQuality];
}

/*
 RTP statistics
 ==
 uint64_t packet_sent;        // number of outgoing packets
 uint64_t packet_dup_sent;    // number of outgoing duplicate packets
 uint64_t sent;               // outgoing total bytes (excluding IP header)
 uint64_t packet_recv;        // number of incoming packets
 uint64_t packet_dup_recv;    // number of incoming duplicate packets
 uint64_t recv;               // incoming bytes of payload and delivered in time to the application
 uint64_t hw_recv;            // incoming bytes of payload
 uint64_t outoftime;          // number of incoming packets that were received too late
 int64_t  cum_packet_loss;    // cumulative number of incoming packet lost
 uint64_t bad;                // incoming packets that did not appear to be RTP
 uint64_t discarded;          // incoming packets discarded because the queue exceeds its max size
 uint64_t sent_rtcp_packets;  // outgoing RTCP packets counter (only packets that embed a report block are considered)
 uint64_t recv_rtcp_packets;  // incoming RTCP packets counter (only packets that embed a report block are considered)
 
 ==
 CallDesc: Start time, Call ID, From address, To address, Duration
 Codec: Codec, Bit rate, Clock rate
 
 BW Usage: download BW(kbits/s), upload BW (kbits/s), sender loss rate, receiver loss rate, cumulative number of late packets,
 sender interarrival jitter, receiver interarrival jitter, jitter buffer size (in ms), roundtrip delay(in sec), call quality
 1
 2
 .
 .
 N
 
 Outgoing data: Total packets, Duplicate packets, Total bytes
 Incoming data: Total packets, Duplicate packets, Bytes of payload, Bytes of payload delivered to app, Packet lost, Received too late, Bad format,
 Discarded due to queue overflow
 RTCP packets: Sent, Received
 Call quality: Computed value, User rating, Reason selected, User comments;
 */
-(void) rtpStats:(LinphoneCall*) curCall {

    KLog(@"rtpStats");
    
    if(!curCall) {
        KLog(@"curcall obj is nil");
        return;
    }
    
    if(!thisCallLog) {
        KLog(@"thisCallLog obj is nil");
        return;
    }
    
    LinphoneCallStats* callStats = linphone_call_get_audio_stats(curCall);
    const rtp_stats_t* rtp = linphone_call_stats_get_rtp_stats(callStats);
    
    float averagedCallQuality = 0.0;
    NSString* errInfo = @"";
    
    if(thisCallLog) {
        //const char* log = linphone_call_log_to_str(thisCallLog);
        averagedCallQuality = linphone_call_log_get_quality(thisCallLog);
        //NSString* callDesc = [NSString stringWithUTF8String:log];
        LinphoneErrorInfo* lpErrInfo = (LinphoneErrorInfo*) linphone_call_log_get_error_info(thisCallLog);
        if(lpErrInfo != NULL) {
            const char* ei = linphone_error_info_get_phrase(lpErrInfo);
            if(ei)
                errInfo = [NSString stringWithUTF8String:ei];
        }
    }
    time_t time = linphone_call_log_get_start_date(thisCallLog);
    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd:HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *dateInString = [dateFormatter stringFromDate:startDate];
    
    //NSString* startTime = [startDate descriptionWithLocale:[NSLocale systemLocale]];
    
    LinphoneAddress* lpFromAddress = linphone_call_log_get_from_address(thisCallLog);
    const char* from_address = linphone_address_as_string(lpFromAddress);
    LinphoneAddress* lpToAddress = linphone_call_log_get_to_address(thisCallLog);
    const char* to_address = linphone_address_as_string(lpToAddress);
    if(sToNumber.length<=0)
        sToNumber = [NSString stringWithUTF8String:to_address];
    
    clMgr.calledNymber = sToNumber;
    clMgr.callerNumber = [NSString stringWithUTF8String:from_address];
    
    int duration = linphone_call_log_get_duration(thisCallLog);
    const char* callID = linphone_call_log_get_call_id(thisCallLog);
    clMgr.log.callID = [NSString stringWithUTF8String:callID];
    
    NSString* callDescHdr = [NSString stringWithFormat:@"#ios-Incoming call at, Call ID, From address, To address, Duration (in secs), Codec, Bit rate, Clock rate\n"];
    NSString* callDesc = [NSString stringWithFormat:@"%@,%s,%s,%@,%d,%@,%ld,%ld\n",
                          dateInString, callID, from_address, sToNumber, duration,codec,(long)bitRate,clockRate];
    clMgr.log.callDescHdr = callDescHdr;
    clMgr.log.callDesc = callDesc;
    /*
    NSString* codecUsedHdr = [NSString stringWithFormat:@"Codec, Bit rate, Clock rate\n"];
    NSString* codecUsed = [NSString stringWithFormat:@"%@, %ld, %ld\n", codec, (long)bitRate, clockRate];
    clMgr.log.codecUsedHdr = codecUsedHdr;
    clMgr.log.codecUsed = codecUsed;
    */
    
    NSString* outgoingDataHdr = [NSString stringWithFormat:@"#Total packets sent, Duplicate packets sent, Total bytes sent\n"];
    NSString* outgoingData = [NSString stringWithFormat:@"%llu,%llu,%llu\n",rtp->packet_sent, rtp->packet_dup_sent, rtp->sent];
    clMgr.log.dataOutgoingHdr = outgoingDataHdr;
    clMgr.log.dataOutgoing = outgoingData;
    
    NSString* incomingDataHdr = [NSString stringWithFormat:@"#Total packets recvd, Duplicate packets recvd, Bytes of payload recvd, Bytes of payload delivered to app, Packet lost, Received too late, Recvd in bad format, Discarded due to queue overflow\n"];
    NSString* incomingData = [NSString stringWithFormat:@"%llu,%llu,%llu,%llu,%llu,%llu,%llu,%llu\n",
                              rtp->packet_recv, rtp->packet_dup_recv, rtp->hw_recv, rtp->recv, rtp->cum_packet_loss, rtp->outoftime, rtp->bad,
                              rtp->discarded];
    clMgr.log.dataIncomingHdr = incomingDataHdr;
    clMgr.log.dataIncoming = incomingData;
    
    NSString* rtcpPacketsHdr = [NSString stringWithFormat:@"#RTCP packets sent, received\n"];
    NSString* rtcpPackets = [NSString stringWithFormat:@"%llu,%llu\n", rtp->sent_rtcp_packets, rtp->recv_rtcp_packets];
    clMgr.log.rtcpPacketsHdr = rtcpPacketsHdr;
    clMgr.log.rtcpPackets = rtcpPackets;
    
    NSString* bwUsageHdr = [NSString stringWithFormat:@"#Download BW(kbits/s), Upload BW (kbits/s), Sender loss rate, Receiver loss rate, Cumulative number of late packets, Sender interarrival jitter, Receiver interarrival jitter, Jitter buffer size (in ms), Roundtrip delay(in sec), Call quality\n"];
    clMgr.log.bwUsageHdr = bwUsageHdr;
    clMgr.log.bwUsage = bwUsage;
    
    //NSString* callQualityDescHdr = [NSString stringWithFormat:@"Computed value, User rating, Reason selected, User comments\n"];
    NSString* callQualityDesc = [NSString stringWithFormat:@"%.1f",averagedCallQuality];
    clMgr.log.callQuality = callQualityDesc;
    
    [clMgr save];
    NSString* cl = [clMgr prepareCallLog];
    if(cl.length) {
        EnLogd(@"Call stats log === \n%@",cl);
    }
}

/*
-(void)showObdWarning:(NSString*)info  Title:(NSString*)title {
    
    acObdCall = [UIAlertController alertControllerWithTitle:title
                                                       message:info
                                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* cancelBtn = [UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil];
    [acObdCall addAction:cancelBtn];
    acObdCall.view.tintColor = [UIColor blueColor];
    AppDelegate* appDelegate = (AppDelegate *)APP_DELEGATE;
    [appDelegate.getNavController presentViewController:acObdCall animated:YES completion:nil];
}*/


/*
 checkMicrophonePermission and showMicrophoneAccessWarning are present in BaseUI as well.
 TODO: Hhave these two methods in common place
 */
-(BOOL)checkMicrophonePermission:(NSString*)text
{
    __block BOOL value = FALSE;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted)
        {
            value = TRUE;
        }
        else
        {
            //[self performSelectorOnMainThread:@selector(showMicrophoneAccessWarning:) withObject:text waitUntilDone:NO];
        }
    }];
    return value;
}

-(void)showMicrophoneAccessWarning:(NSString*)text
{
    
    NSString* msg = @"Callers won't be able to hear your voice when you answer the ReachMe call. Tap Settings to turn on Microphone.";
    if(text.length)
        msg = [NSString stringWithString:text];
    
    acMicrophone = [UIAlertController alertControllerWithTitle:@"You Denied Microphone Access to \"ReachMe\""
                                                       message:msg
                                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okBtn = [UIAlertAction actionWithTitle:@"Settings"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                                                         options:@{}
                                                                               completionHandler:^(BOOL success) {
                                                                                   //KLog(@"success = %d", success);
                                                                               }];
                                                  }];
    
    UIAlertAction* cancelBtn = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil];
    [acMicrophone addAction:okBtn];
    [acMicrophone addAction:cancelBtn];
    acMicrophone.view.tintColor = [UIColor blueColor];
    AppDelegate* appDelegate = (AppDelegate *)APP_DELEGATE;
    [appDelegate.getNavController presentViewController:acMicrophone animated:YES completion:nil];
}

-(void)dismisAlert{
    if(acMicrophone) {
        [acMicrophone dismissViewControllerAnimated:YES completion:nil];
        acMicrophone = nil;
    }
}

#pragma mark -
/*
- (void)selectCallOption:(NSString*)phoneNumber {
    
    acObdCallOption = [UIAlertController alertControllerWithTitle:@"DIAL THE CONTACT VIA FOLLOWING"
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* appToAppCall = [UIAlertAction actionWithTitle:@"App to App"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
        
        
    }];
    
    UIAlertAction* appToGsmCall = [UIAlertAction actionWithTitle:@"App to Mobile number"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
        
    }];
    
    [acObdCallOption addAction:appToAppCall];
    [acObdCallOption addAction:appToGsmCall];
    [acObdCallOption addAction:cancel];
    
    acObdCallOption.view.tintColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    AppDelegate* appDelegate = (AppDelegate *)APP_DELEGATE;
    [appDelegate.getNavController presentViewController:acObdCallOption animated:YES completion:nil];
}
*/

@end