/*
 * iAmYansi Holo controller — V0 hardware interaction firmware.
 * Target: ESP32-class board.
 *
 * This prototype handles local sensing/feedback and a simple BLE command
 * channel. Optical projection/display hardware is intentionally abstracted.
 */

#include <Arduino.h>
#include <Wire.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Replace with the actual IMU / ToF drivers when hardware is selected.
constexpr int STATUS_LED_PIN = 2;
constexpr int HAPTIC_PIN = 4;
constexpr int WAKE_PIN = 15;

constexpr uint32_t SENSOR_INTERVAL_MS = 20;
constexpr uint32_t HEARTBEAT_MS = 1000;

static BLECharacteristic* txCharacteristic = nullptr;
static bool deviceConnected = false;
static uint32_t lastSensorMs = 0;
static uint32_t lastHeartbeatMs = 0;

static const char* SERVICE_UUID = "6b6f6c6f-7961-616e-7369-686f6c6f3031";
static const char* RX_UUID      = "6b6f6c6f-7961-616e-7369-686f6c6f3032";
static const char* TX_UUID      = "6b6f6c6f-7961-616e-7369-686f6c6f3033";

void pulseHaptic(uint16_t ms) {
  digitalWrite(HAPTIC_PIN, HIGH);
  delay(ms);
  digitalWrite(HAPTIC_PIN, LOW);
}

void sendEvent(const String& event) {
  if (!deviceConnected || txCharacteristic == nullptr) return;
  txCharacteristic->setValue(event.c_str());
  txCharacteristic->notify();
}

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer*) override {
    deviceConnected = true;
    digitalWrite(STATUS_LED_PIN, HIGH);
    sendEvent("READY");
  }

  void onDisconnect(BLEServer* server) override {
    deviceConnected = false;
    digitalWrite(STATUS_LED_PIN, LOW);
    server->getAdvertising()->start();
  }
};

class RxCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* characteristic) override {
    const std::string value = characteristic->getValue();
    if (value.empty()) return;

    String command(value.c_str());
    command.trim();
    command.toUpperCase();

    if (command == "WAKE") {
      digitalWrite(STATUS_LED_PIN, HIGH);
      pulseHaptic(40);
      sendEvent("YANSI_WAKE");
    } else if (command == "SLEEP") {
      digitalWrite(STATUS_LED_PIN, LOW);
      sendEvent("YANSI_SLEEP");
    } else if (command == "PING") {
      sendEvent("PONG");
    } else if (command == "HAPTIC") {
      pulseHaptic(80);
      sendEvent("HAPTIC_OK");
    } else if (command == "STATUS") {
      sendEvent(deviceConnected ? "STATUS_CONNECTED" : "STATUS_IDLE");
    }
  }
};

void setupBle() {
  BLEDevice::init("iAmYansi-Holo");
  BLEServer* server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  BLEService* service = server->createService(SERVICE_UUID);

  BLECharacteristic* rx = service->createCharacteristic(
      RX_UUID, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
  rx->setCallbacks(new RxCallbacks());

  txCharacteristic = service->createCharacteristic(
      TX_UUID, BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
  txCharacteristic->addDescriptor(new BLE2902());

  service->start();
  server->getAdvertising()->addServiceUUID(SERVICE_UUID);
  server->getAdvertising()->start();
}

void setup() {
  pinMode(STATUS_LED_PIN, OUTPUT);
  pinMode(HAPTIC_PIN, OUTPUT);
  pinMode(WAKE_PIN, INPUT_PULLUP);
  digitalWrite(STATUS_LED_PIN, LOW);
  digitalWrite(HAPTIC_PIN, LOW);

  Wire.begin();
  setupBle();
}

void loop() {
  const uint32_t now = millis();

  // Local wake input prototype. Replace with capacitive/proximity logic later.
  static bool previousWake = HIGH;
  const bool wake = digitalRead(WAKE_PIN);
  if (previousWake == HIGH && wake == LOW) {
    sendEvent("WAKE_GESTURE");
    digitalWrite(STATUS_LED_PIN, HIGH);
    pulseHaptic(35);
  }
  previousWake = wake;

  // Sensor sampling slot. IMU/ToF drivers will publish structured events here.
  if (now - lastSensorMs >= SENSOR_INTERVAL_MS) {
    lastSensorMs = now;
    // TODO: read IMU orientation, acceleration and ToF distance.
  }

  if (now - lastHeartbeatMs >= HEARTBEAT_MS) {
    lastHeartbeatMs = now;
    if (deviceConnected) sendEvent("HEARTBEAT");
  }

  delay(1);
}
