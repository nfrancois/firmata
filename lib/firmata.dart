library serial_port;

import 'dart:async';
import 'dart:isolate';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;
import 'package:serial_port/serial_port.dart';

part 'src/board.dart';
part 'src/sysex_parser.dart';


// Constants
const int PIN_MODE = 0xF4;
const int REPORT_DIGITAL = 0xD0;
const int REPORT_ANALOG = 0xC0;
const int DIGITAL_MESSAGE = 0x90;
const int START_SYSEX = 0xF0;
const int END_SYSEX = 0xF7;

const int QUERY_FIRMWARE = 0x79;
const int REPORT_VERSION = 0xF9;
const int ANALOG_MESSAGE = 0xE0;
//const int EXTENDED_ANALOG = 0x6F;
const int CAPABILITY_QUERY = 0x6B;
//const int CAPABILITY_RESPONSE = 0x6C;
//const int PIN_STATE_QUERY = 0x6D;
//const int PIN_STATE_RESPONSE = 0x6E;
const int ANALOG_MAPPING_QUERY = 0x69;
//const int ANALOG_MAPPING_RESPONSE = 0x6A;
//const int I2C_REQUEST = 0x76;
//const int I2C_REPLY = 0x77;
//const int I2C_CONFIG = 0x78;
//const int STRING_DATA = 0x71;
//const int SYSTEM_RESET = 0xFF;
//const int PULSE_OUT = 0x73;
//const int PULSE_IN = 0x74;
//const int SAMPLING_INTERVAL = 0x7A;
//const int STEPPER = 0x72;
//const int ONEWIRE_DATA = 0x73;
//const int ONEWIRE_CONFIG_REQUEST = 0x41;
//const int ONEWIRE_SEARCH_REQUEST = 0x40;
//const int ONEWIRE_SEARCH_REPLY = 0x42;
//const int ONEWIRE_SEARCH_ALARMS_REQUEST = 0x44;
//const int ONEWIRE_SEARCH_ALARMS_REPLY = 0x45;
//const int ONEWIRE_READ_REPLY = 0x43;
//const int ONEWIRE_RESET_REQUEST_BIT = 0x01;
//const int ONEWIRE_READ_REQUEST_BIT = 0x08;
//const int ONEWIRE_DELAY_REQUEST_BIT = 0x10;
//const int ONEWIRE_WRITE_REQUEST_BIT = 0x20;
//const int ONEWIRE_WITHDATA_REQUEST_BITS = 0x3C;
