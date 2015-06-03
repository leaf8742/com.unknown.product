#import "DeviceManager.h"
#import "Model.h"
#import "MainMenuViewController.h"

NSString *const StopScan = @"StopScan";
NSString *const KeyStateService = @"KeyStateService";

@interface DeviceManager()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *manager;

@property (strong, nonatomic) CBCharacteristic *alertCharacteristic;

@property (strong, nonatomic) NSTimer *timer;

@end

// 0F67E8DA-DCD3-F3D8-9338-9DF4CF473CA4 白

/// ^ BLE_UUID_BATTERY_SERVICE
#define     BLE_UUID_BATTERY_SERVICE   @"180F"

/// ^ Device Information
#define     BLE_UUID_DEVICE_INFORMATION_SERVICE   @"180A"

/// ^ BLE_UUID_IMMEDIATE_ALERT_SERVICE
#define     BLE_UUID_IMMEDIATE_ALERT_SERVICE   @"1802"

///
#define     BLE_UUID_ALERT_LEVEL_SERVICE   @"2A06"

/// ^ BLE_UUID_KEY_STATE_SERVICE
#define     BLE_UUID_KEY_STATE_SERVICE   @"FFE0"

@implementation DeviceManager

@synthesize alertDistance = _alertDistance;

- (id)init {
    if (self = [super init]) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        id alertDistance = [[NSUserDefaults standardUserDefaults] valueForKey:@"alertDistance"];
        if (alertDistance) {
            self.alertDistance = [alertDistance integerValue];
        } else {
            self.alertDistance = 100;
        }
    }
    return self;
}

- (NSInteger)alertDistance {
    return _alertDistance;
}

- (void)setAlertDistance:(NSInteger)alertDistance {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:alertDistance] forKey:@"alertDistance"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    _alertDistance = alertDistance;
}

+ (void)scan {
    [[DeviceManager sharedInstance].manager scanForPeripheralsWithServices:nil
                                                                   options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

+ (void)stopScan {
    [[DeviceManager sharedInstance].manager stopScan];
    [[NSNotificationCenter defaultCenter] postNotificationName:StopScan object:nil];
}

+ (void)connectPeripheral:(CBPeripheral *)peripheral {
    [[DeviceManager sharedInstance].manager connectPeripheral:peripheral options:nil];
}

+ (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    if (peripheral.services != nil) {
        for (CBService *service in peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        // It is notifying, so unsubscribe
                        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        
                        // And we're done.
//                        return;
                    }
                }
            }
        }
    }
    
    [[DeviceManager sharedInstance].manager cancelPeripheralConnection:peripheral];
}

+ (void)alert:(CBPeripheral *)peripheral {
    if ([DeviceManager sharedInstance].alertCharacteristic) {
        Byte byte = 2;
        [peripheral writeValue:[NSData dataWithBytes:&byte length:1] forCharacteristic:[DeviceManager sharedInstance].alertCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

#pragma mark - Signleton Implementation
+ (instancetype)sharedInstance {
    static id sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [NSAllocateObject([self class], 0, NULL) init];
    });
    return sharedClient;
}

+ (id)allocWithZone:(NSZone *)zone {
    static id result;
    result = nil;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        result = [self sharedInstance];
    });
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
//            [self.manager scanForPeripheralsWithServices:nil
//                                                 options:@{CBCentralManagerScanOptionAllowDuplicatesKey :
//                                                               @YES}];
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripheral.name isEqualToString:@"ITAG"]) {
        return;
    }
    
    // Stops scanning for peripheral
    [DeviceManager stopScan];
    
    CameraInformation *camera = [UserInformation objectWithIdentifier:peripheral.identifier type:kObjectTypeCamera];
    camera.peripheral = peripheral;
    camera.title = peripheral.name;
    if (![[[UserInformation sharedInstance] objects] containsObject:camera]) {
        [[[UserInformation sharedInstance] mutableArrayValueForKey:@"objects"] addObject:camera];
    }
    [DeviceManager connectPeripheral:peripheral];

//    if (self.peripheral != peripheral) {
//        self.peripheral = peripheral;
//        NSLog(@"Connecting to peripheral %@", peripheral);
//        // Connects to the discovered peripheral
//        [self.manager connectPeripheral:peripheral options:nil];
//    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // Clears the data that we may already have
    // Sets the peripheral delegate
    [peripheral setDelegate:self];
    // Asks the peripheral to discover the service
    [peripheral discoverServices:nil];
    
    CameraInformation *camera = [UserInformation objectWithIdentifier:peripheral.identifier type:kObjectTypeCamera];
    [[NSNotificationCenter defaultCenter] postNotificationName:RadarObject object:camera];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    CameraInformation *camera = [UserInformation objectWithIdentifier:peripheral.identifier type:kObjectTypeCamera];
    camera.RSSI = peripheral.RSSI;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    CameraInformation *camera = [UserInformation objectWithIdentifier:peripheral.identifier type:kObjectTypeCamera];
    camera.RSSI = RSSI;
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service:%@", [error localizedDescription]);
        [DeviceManager cancelPeripheralConnection:aPeripheral];
        return;
    }
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Service found with UUID: %@",
              service.UUID);
        // Discovers the characteristics for a given service
        [aPeripheral discoverCharacteristics:service.characteristics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        [DeviceManager cancelPeripheralConnection:peripheral];
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.service.UUID.UUIDString isEqualToString:@"FFE0"] &&
            [characteristic.UUID.UUIDString isEqualToString:@"FFE1"]) {
            [peripheral setNotifyValue:YES
                     forCharacteristic:characteristic];
        } else if ([characteristic.service.UUID.UUIDString isEqualToString:@"180F"] &&
                   [characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
            [peripheral setNotifyValue:YES
                     forCharacteristic:characteristic];
        }
        
        if (characteristic.isNotifying) {
            [peripheral setNotifyValue:YES
                     forCharacteristic:characteristic];
        } else {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        CBCharacteristic *characteristic = characteristic;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Exits if it's not the transfer characteristic
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    } else { // Notification has stopped
//        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CBService *service = characteristic.service;
    if ([service.UUID isEqual:[CBUUID UUIDWithString:BLE_UUID_DEVICE_INFORMATION_SERVICE]]) {
        NSLog(@"characteristic: %@", characteristic);
        NSLog(@"value: %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    } else {
        if ([characteristic.service.UUID.UUIDString isEqualToString:@"FFE0"] &&
            [characteristic.UUID.UUIDString isEqualToString:@"FFE1"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KeyStateService object:nil];
        } else if ([characteristic.service.UUID.UUIDString isEqualToString:@"180F"] &&
                   [characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
#warning 更新电量
        } else if ([characteristic.service.UUID.UUIDString isEqualToString:BLE_UUID_IMMEDIATE_ALERT_SERVICE] &&
                   [characteristic.UUID.UUIDString isEqualToString:BLE_UUID_ALERT_LEVEL_SERVICE]) {
            self.alertCharacteristic = characteristic;
        }
        
        NSLog(@"characteristic: %@", characteristic);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"%@", descriptor);
}

@end
