# SecureTrack SL - Driver & Customs Inspector Mobile Module

Developed by **Idusha** (Basnayaka I.K.) for the SecureTrack SL IoT Framework.

## Features Implemented

### 1. Transport Driver Module
- **Assigned Trip Navigation:** Displays the approved Customs geofence corridor on an interactive Leaflet map.
- **Trip Lifecycle Management:** Start Trip and End Trip controls with live status synchronization to Java Spring Boot backend (`/api/trips/{id}/status`).
- **Emergency Incident Reporting:** Instant road emergency and deviation alert reporting directly to Customs Control Room (`POST /api/alerts/driver-report`).
- **Driver Profile & Vehicle Information:** Real-time synchronization of assigned truck number and route metadata.

### 2. Customs Field Inspector Module
- **IoT Hardware Registration:** In-field pairing of ESP32 edge telemetry modules to containers before port exit.
- **Electronic RFID Seal Verification & Clearance:** Authorized unlocking of electronic smart seals upon physical destination arrival (`POST /api/device/unlock`).
- **Active IoT Units Telemetry:** Real-time monitoring of deployed container battery levels and dual-sensor tamper statuses.
- **Duty Terminal Filtering:** Filtering container queues by customs yard / duty terminal.
