const http = require('http');
const url = require('url');
const crypto = require('crypto');

const PORT = 8080;
const SECRET_KEY = 'SecureTrack_SL_Customs_Secret_Key_2026';

// -------------------------------------------------------------
// Registered 9 Users (3 Owners, 3 Drivers, 3 Inspectors, 1 Admin)
// -------------------------------------------------------------
const users = [
  // Admin
  {
    id: 2,
    username: 'superadmin',
    email: 'superadmin@securetrack.lk',
    password: 'Admin@2026',
    fullName: 'Super Admin',
    role: 'ROLE_ADMIN',
    active: true,
    aliases: ['superadmin', 'admin']
  },

  // 3 Owners (SRS Page 36 & DB Match)
  {
    id: 4,
    username: 'owner1',
    email: 'owner1@securetrack.lk',
    password: 'Owner@2026',
    fullName: 'Lanka Logistics Ltd',
    companyName: 'Lanka Logistics Ltd',
    phone: '+94 11 234 5678',
    role: 'ROLE_OWNER',
    active: true,
    containerNos: ['CONT-LK-001', 'CGO-1004'],
    aliases: ['owner1', 'owner1@securetrack.lk', 'lanka', 'info@lankalogistics.lk']
  },
  {
    id: 3,
    username: 'randil',
    email: 'randil@gmail.com',
    password: 'Owner@2026',
    fullName: 'Randil Silva',
    companyName: 'Cargo Overseas Logistics',
    phone: '+94 11 789 0123',
    role: 'ROLE_OWNER',
    active: true,
    containerNos: ['CGO-1002'],
    aliases: ['owner2', 'owner2@securetrack.lk', 'randil@gmail.com', 'owner@cargooverseas.lk', 'randil', 'owner']
  },
  {
    id: 5,
    username: 'owner3',
    email: 'owner3@securetrack.lk',
    password: 'Owner@2026',
    fullName: 'Ceylon Freight Global',
    companyName: 'Ceylon Freight Global',
    phone: '+94 11 456 7890',
    role: 'ROLE_OWNER',
    active: true,
    containerNos: ['CGO-1001', 'CGO-1003'],
    aliases: ['owner3', 'owner3@securetrack.lk', 'ceylon', 'ceylonfreight']
  },

  // 5 Drivers (DB Aligned: 4 DB Originals + Roshen Alwis)
  {
    id: 2,
    username: 'uvindu',
    email: 'uvindu@gmail.com',
    password: 'Driver@2026',
    fullName: 'Uvindu Bandara',
    phone: '+94 77 123 4567',
    licenseNo: 'B-1234567',
    vehicleNo: 'cp-pt-2943',
    vehicleModel: 'Prime Mover',
    company: 'Lanka Logistics Ltd',
    rating: '4.9',
    experience: '9 Years',
    status: 'AVAILABLE',
    role: 'ROLE_DRIVER',
    active: true,
    assignedTrip: {
      tripId: '61',
      containerNo: 'CONT-LK-001',
      status: 'AVAILABLE',
      destination: 'Katunayake BOI',
      startLocation: 'Colombo Port Gate 01',
      distanceLeft: '33.2 km',
      eta: '45 mins',
      progressPercent: 0,
      weight: '24,500 kg',
      type: '40ft HC (High Cube)',
      sealStatus: 'Locked (TAG-12345 / IOT-DEV-001)',
      currentLat: 6.9497,
      currentLng: 79.8433
    },
    aliases: ['uvindu', 'uvindu@gmail.com', 'driver1', 'driver1@securetrack.lk', 'b-1234567']
  },
  {
    id: 4,
    username: '962510703v',
    email: '962510703v@registered.securetrack',
    password: 'Driver@2026',
    fullName: 'Dilshan',
    phone: '+94 77 123 4578',
    licenseNo: 'B-7654321',
    vehicleNo: 'LL-8666',
    vehicleModel: 'Layland',
    company: 'Ceylon Freight Fleet',
    rating: '4.8',
    experience: '6 Years',
    status: 'AVAILABLE',
    role: 'ROLE_DRIVER',
    active: true,
    assignedTrip: {
      tripId: '62',
      containerNo: 'CGO-1001',
      status: 'AVAILABLE',
      destination: 'Katunayake FTZ',
      startLocation: 'Colombo Port Gate 04',
      distanceLeft: '28.5 km',
      eta: '38 mins',
      progressPercent: 0,
      weight: '18,200 kg',
      type: '20ft Standard',
      sealStatus: 'Locked (TAG-90821 / IOT-DEV-002)',
      currentLat: 6.9497,
      currentLng: 79.8433
    },
    aliases: ['962510703v', 'dilshan', 'driver2', 'driver2@securetrack.lk', 'b-7654321']
  },
  {
    id: 3,
    username: '962510202v',
    email: '962510202v@registered.securetrack',
    password: 'Driver@2026',
    fullName: 'Nimantha Bandara',
    phone: '+94 77 123 4560',
    licenseNo: 'B-49201948',
    vehicleNo: 'LC-2225',
    vehicleModel: 'Tata',
    company: 'Cargo Overseas Hauliers',
    rating: '5.0',
    experience: '8 Years',
    status: 'AVAILABLE',
    role: 'ROLE_DRIVER',
    active: true,
    assignedTrip: {
      tripId: '63',
      containerNo: 'CGO-1002',
      status: 'AVAILABLE',
      destination: 'Biyagama FTZ',
      startLocation: 'Peliyagoda Yard',
      distanceLeft: '21.0 km',
      eta: '30 mins',
      progressPercent: 0,
      weight: '22,000 kg',
      type: '40ft Refrigerated',
      sealStatus: 'Locked (TAG-55441 / IOT-DEV-003)',
      currentLat: 6.9497,
      currentLng: 79.8433
    },
    aliases: ['962510202v', 'nimantha', 'driver3', 'driver3@securetrack.lk', 'driver@cargooverseas.lk', 'b-49201948']
  },
  {
    id: 5,
    username: '962510580v',
    email: '962510580v@registered.securetrack',
    password: 'Driver@2026',
    fullName: 'Matheesha',
    phone: '+94 77 123 4111',
    licenseNo: 'B-8812041',
    vehicleNo: 'PT-2943',
    vehicleModel: 'Nissan',
    company: 'Ceylon Freight Fleet',
    rating: '4.8',
    experience: '5 Years',
    status: 'AVAILABLE',
    role: 'ROLE_DRIVER',
    active: true,
    assignedTrip: {
      tripId: '65',
      containerNo: 'CGO-1003',
      status: 'AVAILABLE',
      destination: 'Biyagama Export Zone',
      startLocation: 'Colombo Port',
      distanceLeft: '0.0 km',
      eta: 'Available',
      progressPercent: 100,
      weight: '12,800 kg',
      type: '20ft Standard',
      sealStatus: 'Disarmed (TAG-33120)',
      currentLat: 6.9405,
      currentLng: 79.9850
    },
    aliases: ['962510580v', 'matheesha', 'driver5', 'driver5@securetrack.lk', 'b-8812041']
  },
  {
    id: 6,
    username: '962510991v',
    email: 'roshen@securetrack.lk',
    password: 'Driver@2026',
    fullName: 'Roshen Alwis',
    phone: '+94 77 334 5566',
    licenseNo: 'B-3321908',
    vehicleNo: 'WP-CBE-9901',
    vehicleModel: 'Ashok Leyland Captain',
    company: 'Lanka Logistics Ltd',
    rating: '4.7',
    experience: '5 Years',
    status: 'AVAILABLE',
    role: 'ROLE_DRIVER',
    active: true,
    assignedTrip: {
      tripId: '64',
      containerNo: 'CGO-1004',
      status: 'AVAILABLE',
      destination: 'Katunayake BOI',
      startLocation: 'Colombo Port Holding Area',
      distanceLeft: '34.0 km',
      eta: 'Available',
      progressPercent: 0,
      weight: '26,100 kg',
      type: '40ft Refrigerated',
      sealStatus: 'Locked (TAG-77112 / IOT-DEV-004)',
      currentLat: 6.9426,
      currentLng: 79.8623
    },
    aliases: ['962510991v', 'roshen', 'driver4', 'driver4@securetrack.lk', 'b-3321908']
  },

  // 3 Customs Inspectors (SRS Page 36 & DB Match)
  {
    id: 13,
    username: 'inspector1',
    email: 'hasitha@gmail.com',
    password: 'Customs@2026',
    fullName: 'Hasitha Dana',
    badgeNo: 'INSP-13',
    dutyStation: 'Katunayake BOI',
    phone: '+94 11 243 2191 (Ext 8941)',
    role: 'ROLE_INSPECTOR',
    active: true,
    aliases: ['inspector1', 'inspector1@securetrack.lk', 'hasitha@gmail.com', 'hasitha', 'insp-13', 'inspector']
  },
  {
    id: 14,
    username: 'inspector2',
    email: 'inspector2@securetrack.lk',
    password: 'Customs@2026',
    fullName: 'Kavindu Madushan',
    badgeNo: 'INSP-14',
    dutyStation: 'Orugodawatta Customs Yard',
    phone: '+94 11 222 3344 (Ext 4012)',
    role: 'ROLE_INSPECTOR',
    active: true,
    aliases: ['inspector2', 'inspector2@securetrack.lk', 'insp-14', 'kavindu']
  },
  {
    id: 15,
    username: 'inspector3',
    email: 'inspector3@securetrack.lk',
    password: 'Customs@2026',
    fullName: 'Saman Kumara',
    badgeNo: 'INSP-15',
    dutyStation: 'Biyagama FTZ',
    phone: '+94 11 556 7788 (Ext 1205)',
    role: 'ROLE_INSPECTOR',
    active: true,
    aliases: ['inspector3', 'inspector3@securetrack.lk', 'insp-15', 'saman']
  }
];

// Helper for JWT
function generateToken(user) {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({
    sub: user.username,
    id: user.id,
    username: user.username,
    email: user.email,
    role: user.role,
    fullName: user.fullName,
    exp: Math.floor(Date.now() / 1000) + (24 * 3600)
  })).toString('base64url');
  const signature = crypto.createHmac('sha256', SECRET_KEY).update(`${header}.${payload}`).digest('base64url');
  return `${header}.${payload}.${signature}`;
}

function verifyToken(token) {
  if (!token) return null;
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const expectedSig = crypto.createHmac('sha256', SECRET_KEY).update(`${parts[0]}.${parts[1]}`).digest('base64url');
    if (expectedSig !== parts[2]) return null;
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
    if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch (e) {
    return null;
  }
}

// -------------------------------------------------------------
// All Registered Containers with Fleet & RFID Data
// -------------------------------------------------------------
const allContainers = [
  {
    id: '1',
    containerNo: 'CONT-LK-001',
    destination: 'Katunayake BOI',
    currentRoad: 'A3 Highway, Ja-Ela',
    eta: '20 mins',
    status: 'In Transit',
    distanceLeftKm: 14.2,
    speedKmh: 58.0,
    progressPercent: 62,
    sealStatus: 'Closed & Secure (IOT-DEV-001)',
    sealId: 'TAG-12345',
    weight: '24,500 kg',
    type: '40ft HC (High Cube)',
    contents: 'Industrial Electronics & Machinery',
    latitude: 7.0555,
    longitude: 79.8797,
    transporter: 'Lanka Logistics Ltd',
    vehicleNo: 'cp-pt-2943',
    driverName: 'Uvindu Bandara (Lic: B-1234567)',
    rfidTag: 'RFID Tag: TAG-12345 (Cleared at Colombo Port Gate 01)'
  },
  {
    id: '2',
    containerNo: 'CGO-1001',
    destination: 'Katunayake FTZ',
    currentRoad: 'Colombo Port Gate 04',
    eta: '45 mins',
    status: 'In Transit',
    distanceLeftKm: 32.5,
    speedKmh: 35.0,
    progressPercent: 20,
    sealStatus: 'Closed & Secure (ESP32-001)',
    sealId: 'ESEAL-SL-90822',
    weight: '18,200 kg',
    type: '40ft Standard',
    contents: 'Machinery Spare Parts & Sensors',
    latitude: 6.9497,
    longitude: 79.8433,
    transporter: 'Ceylon Freight Fleet',
    vehicleNo: 'LL-8666 (Layland)',
    driverName: 'Dilshan (Lic: B-7654321)',
    rfidTag: 'RFID Tag: TAG-90821 (Cleared at Gate 04)'
  },
  {
    id: '3',
    containerNo: 'CGO-1002',
    destination: 'Biyagama FTZ',
    currentRoad: 'Peliyagoda Interchange',
    eta: '10 mins',
    status: 'In Transit',
    distanceLeftKm: 8.4,
    speedKmh: 42.0,
    progressPercent: 78,
    sealStatus: 'Closed & Secure (BLE-TAG-89)',
    sealId: 'ESEAL-SL-90823',
    weight: '21,400 kg',
    type: '40ft High-Cube',
    contents: 'Solar Inverters & Lithium Cells',
    latitude: 6.9554,
    longitude: 79.8827,
    transporter: 'Cargo Overseas Hauliers',
    vehicleNo: 'LC-2225 (Tata)',
    driverName: 'Nimantha Bandara (Lic: B-49201948)',
    rfidTag: 'RFID Tag: TAG-55441 (Cleared at Baseline Logistics Yard)'
  },
  {
    id: '4',
    containerNo: 'CGO-1003',
    destination: 'Biyagama Export Zone',
    currentRoad: 'Biyagama Zone Internal Yard',
    eta: 'Available',
    status: 'Delivered',
    distanceLeftKm: 0.0,
    speedKmh: 0.0,
    progressPercent: 100,
    sealStatus: 'Disarmed by Customs Officer',
    sealId: 'ESEAL-SL-90819',
    weight: '12,800 kg',
    type: '20ft Standard',
    contents: 'Automotive Sub-assemblies',
    latitude: 6.9405,
    longitude: 79.9850,
    transporter: 'Ceylon Freight Fleet',
    vehicleNo: 'PT-2943 (Nissan)',
    driverName: 'Matheesha (Lic: B-8812041)',
    rfidTag: 'RFID Tag: TAG-33120 (Disarmed at Biyagama Gates)'
  },
  {
    id: '5',
    containerNo: 'CGO-1004',
    destination: 'Katunayake BOI',
    currentRoad: 'Colombo Port Holding Area',
    eta: 'Available',
    status: 'In Transit',
    distanceLeftKm: 34.0,
    speedKmh: 0.0,
    progressPercent: 5,
    sealStatus: 'Active - Armed (Pending Dispatch)',
    sealId: 'ESEAL-SL-90824',
    weight: '26,100 kg',
    type: '40ft Refrigerated',
    contents: 'Pharmaceutical Grade Reagents',
    latitude: 6.9426,
    longitude: 79.8623,
    transporter: 'Lanka Logistics Ltd',
    vehicleNo: 'WP-CBE-9901 (Ashok Leyland Captain)',
    driverName: 'Roshen Alwis (Lic: B-3321908)',
    rfidTag: 'RFID Tag: TAG-77112 (Pending Dispatch)'
  }
];

// Alerts
const alerts = [
  {
    id: 1,
    containerNo: 'CONT-LK-001',
    alertType: 'SEAL_BROKEN',
    severity: 'HIGH',
    status: 'PENDING',
    message: 'Seal/magnet sensor reports open state on container CONT-LK-001 (awaiting light-sensor confirmation)',
    location: 'Colombo Port',
    timestamp: '2026-10-21 14:20:15'
  },
  {
    id: 2,
    containerNo: 'CGO-1001',
    alertType: 'ROUTE_DEVIATION',
    severity: 'HIGH',
    status: 'PENDING',
    message: 'Container deviated from planned route by 2.5km',
    location: 'Peliyagoda Bypass',
    timestamp: '2026-10-21 15:05:30'
  },
  {
    id: 3,
    containerNo: 'CGO-1002',
    alertType: 'GEOFENCE_EXIT',
    severity: 'MEDIUM',
    status: 'PENDING',
    message: 'Container left the authorized geofence zone',
    location: 'Hambantota Port Entrance',
    timestamp: '2026-10-21 15:35:45'
  },
  {
    id: 4,
    containerNo: 'CGO-1003',
    alertType: 'SPEED_VIOLATION',
    severity: 'LOW',
    status: 'RESOLVED',
    message: 'Vehicle speed exceeded 80 km/h threshold',
    location: 'Southern Expressway E01',
    timestamp: '2026-10-21 13:12:00'
  }
];

const geofences = [
  { id: 1, name: 'Colombo Port Zone', type: 'PORT', radius: 1500, latitude: 6.9497, longitude: 79.8433 },
  { id: 2, name: 'Biyagama FTZ', type: 'INDUSTRIAL', radius: 2000, latitude: 6.9405, longitude: 79.9850 },
  { id: 3, name: 'Katunayake EPZ', type: 'AIRPORT_ZONE', radius: 2500, latitude: 7.1703, longitude: 79.8839 }
];

const auditLogs = [
  { id: 1, action: 'LOGIN', username: 'superadmin', details: 'Successful sign-in to Admin Console', timestamp: '2026-10-21 16:30:12' },
  { id: 2, action: 'ALERT_ACK', username: 'hasitha', details: 'Acknowledged SEAL_BROKEN on CONT-LK-001', timestamp: '2026-10-21 15:45:00' },
  { id: 3, action: 'ROUTE_ASSIGN', username: 'custom_officer', details: 'Assigned Colombo-Katunayake route to CGO-1001', timestamp: '2026-10-21 14:10:22' }
];

// OSRM sample route
const sampleRouteJson = JSON.stringify({
  routes: [
    {
      geometry: {
        coordinates: [
          [79.8442, 6.9495],
          [79.8462, 6.9410],
          [79.8480, 6.9365],
          [79.8505, 6.9310],
          [79.8600, 6.9550],
          [79.8700, 7.0200],
          [79.8750, 7.1000],
          [79.8839, 7.1703]
        ]
      }
    }
  ]
});

const server = http.createServer((req, res) => {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', () => {
    let jsonBody = {};
    if (body) {
      try { jsonBody = JSON.parse(body); } catch (e) {}
    }

    const sendJson = (statusCode, data) => {
      res.writeHead(statusCode, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(data));
    };

    // Helper to get authenticated user from Bearer header
    const authHeader = req.headers['authorization'] || '';
    let authenticatedUser = null;
    if (authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const payload = verifyToken(token);
      if (payload) {
        authenticatedUser = users.find(u => u.username === payload.username || u.id === payload.id);
      }
    }

    // -------------------------------------------------------------
    // 1. Strict Authenticate Login (/auth/login)
    // -------------------------------------------------------------
    if (req.method === 'POST' && pathname === '/auth/login') {
      const identifier = (jsonBody.username || jsonBody.email || '').trim().toLowerCase();
      const password = (jsonBody.password || '').trim();

      if (!identifier || !password) {
        return sendJson(400, {
          success: false,
          message: 'Username/Email and password are required'
        });
      }

      // Find user by username, email, licenseNo, or aliases
      const user = users.find(u =>
        u.username.toLowerCase() === identifier ||
        u.email.toLowerCase() === identifier ||
        (u.licenseNo && u.licenseNo.toLowerCase() === identifier) ||
        (u.aliases && u.aliases.map(a => a.toLowerCase()).includes(identifier))
      );

      if (!user) {
        return sendJson(401, {
          success: false,
          message: 'Invalid credentials: User account not found in SecureTrack SL directory'
        });
      }

      // Validate Password
      if (user.password !== password) {
        return sendJson(401, {
          success: false,
          message: 'Invalid credentials: Password does not match'
        });
      }

      const token = generateToken(user);

      return sendJson(200, {
        success: true,
        token: token,
        role: user.role,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          role: user.role,
          companyName: user.companyName,
          phone: user.phone,
          vehicleNo: user.vehicleNo,
          licenseNo: user.licenseNo,
          dutyStation: user.dutyStation,
          badgeNo: user.badgeNo,
          containerNos: user.containerNos || [],
          assignedTrip: user.assignedTrip || null
        }
      });
    }

    // -------------------------------------------------------------
    // 2. Authenticated User Profile (/api/users/me)
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname === '/api/users/me') {
      if (!authenticatedUser) {
        return sendJson(401, {
          success: false,
          message: 'Unauthorized: Valid Bearer token required'
        });
      }

      return sendJson(200, {
        id: authenticatedUser.id,
        username: authenticatedUser.username,
        email: authenticatedUser.email,
        fullName: authenticatedUser.fullName,
        role: authenticatedUser.role,
        companyName: authenticatedUser.companyName,
        phone: authenticatedUser.phone,
        vehicleNo: authenticatedUser.vehicleNo,
        licenseNo: authenticatedUser.licenseNo,
        dutyStation: authenticatedUser.dutyStation,
        badgeNo: authenticatedUser.badgeNo,
        containerNos: authenticatedUser.containerNos || [],
        assignedTrip: authenticatedUser.assignedTrip || null
      });
    }

    if (req.method === 'PUT' && pathname === '/api/users/me') {
      return sendJson(200, { success: true, message: 'Profile updated successfully' });
    }

    if (req.method === 'POST' && pathname === '/api/users/me/password') {
      return sendJson(200, { success: true, message: 'Password updated successfully' });
    }

    // -------------------------------------------------------------
    // 3. Alerts (/api/alerts)
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname === '/api/alerts') {
      return sendJson(200, alerts);
    }

    if (req.method === 'GET' && pathname.startsWith('/api/alerts/container/')) {
      const containerNo = decodeURIComponent(pathname.replace('/api/alerts/container/', ''));
      const filtered = alerts.filter(a => a.containerNo.toLowerCase() === containerNo.toLowerCase());
      return sendJson(200, filtered);
    }

    if (req.method === 'PUT' && pathname.includes('/acknowledge')) {
      const alertId = parseInt(pathname.split('/')[3], 10);
      const alert = alerts.find(a => a.id === alertId);
      if (alert) alert.status = 'ACKNOWLEDGED';
      return sendJson(200, { success: true, id: alertId, status: 'ACKNOWLEDGED' });
    }

    if (req.method === 'PUT' && pathname.includes('/resolve')) {
      const alertId = parseInt(pathname.split('/')[3], 10);
      const alert = alerts.find(a => a.id === alertId);
      if (alert) alert.status = 'RESOLVED';
      return sendJson(200, { success: true, id: alertId, status: 'RESOLVED' });
    }

    // -------------------------------------------------------------
    // 4. Live Locations for Map (/api/monitoring/live-locations)
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname === '/api/monitoring/live-locations') {
      const ownerParam = parsedUrl.query.owner || (authenticatedUser && authenticatedUser.role === 'ROLE_OWNER' ? authenticatedUser.username : null);
      let list = allContainers;
      if (ownerParam) {
        const ownerUser = users.find(u => u.username === ownerParam || u.email === ownerParam || (u.aliases && u.aliases.includes(ownerParam)));
        if (ownerUser && ownerUser.containerNos) {
          list = allContainers.filter(c => ownerUser.containerNos.includes(c.containerNo));
        }
      }
      // Return both web-required fields (containerId, speed, battery, temp) and mobile-required fields
      return sendJson(200, list.map(c => ({
        ...c,
        containerId: parseInt(c.id, 10) || 1,
        speed: c.speedKmh || 48,
        battery: 94,
        temperature: 24.2,
        lastUpdated: 'Just now'
      })));
    }

    // -------------------------------------------------------------
    // 5. Trip by container (/api/trips/container/:id)
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname.startsWith('/api/trips/container/')) {
      const containerId = pathname.replace('/api/trips/container/', '');
      return sendJson(200, {
        containerId: containerId,
        routeCoordinatesJson: sampleRouteJson,
        startLocation: 'Colombo Port',
        destination: 'Katunayake EPZ',
        status: 'IN_TRANSIT'
      });
    }

    // -------------------------------------------------------------
    // 6. Track container (/api/dashboard/track/:containerNo)
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname.startsWith('/api/dashboard/track/')) {
      const containerNo = decodeURIComponent(pathname.replace('/api/dashboard/track/', ''));
      const found = allContainers.find(c => c.containerNo.toLowerCase() === containerNo.toLowerCase());
      if (found) {
        return sendJson(200, {
          containerNo: found.containerNo,
          status: found.status,
          latitude: found.latitude,
          longitude: found.longitude,
          speed: found.speedKmh,
          temperature: 24.2,
          battery: 94,
          destination: found.destination,
          origin: 'Colombo Port',
          driver: found.driverName,
          vehicleNo: found.vehicleNo,
          eta: found.eta
        });
      }
      return sendJson(200, {
        containerNo: containerNo || 'CONT-LK-001',
        status: 'IN_TRANSIT',
        latitude: 6.9497,
        longitude: 79.8433,
        speed: 48,
        temperature: 24.2,
        battery: 94,
        destination: 'Katunayake EPZ',
        origin: 'Colombo Port',
        driver: 'Sunil Perera',
        vehicleNo: 'WP-CAD-1234',
        eta: '35 mins'
      });
    }

    // -------------------------------------------------------------
    // 7. Reports Summary
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname === '/api/reports/summary') {
      return sendJson(200, {
        statCards: [
          { label: 'Total Shipments', value: '142', trend: '+12%', direction: 'up' },
          { label: 'Active Containers', value: '28', trend: '+4%', direction: 'up' },
          { label: 'Total Alerts', value: '15', trend: '-8%', direction: 'down' },
          { label: 'Resolved Incidents', value: '98%', trend: '+2%', direction: 'up' }
        ],
        shipmentActivity: [
          { day: 'Mon', shipments: 22, completed: 20 },
          { day: 'Tue', shipments: 28, completed: 25 },
          { day: 'Wed', shipments: 35, completed: 32 },
          { day: 'Thu', shipments: 30, completed: 29 },
          { day: 'Fri', shipments: 42, completed: 39 },
          { day: 'Sat', shipments: 18, completed: 17 },
          { day: 'Sun', shipments: 12, completed: 12 }
        ],
        alertDistribution: [
          { name: 'ROUTE_DEVIATION', value: 18, color: '#f59e0b' },
          { name: 'SEAL_BROKEN', value: 5, color: '#ef4444' },
          { name: 'GEOFENCE_EXIT', value: 8, color: '#3b82f6' },
          { name: 'SPEED_VIOLATION', value: 12, color: '#8b5cf6' }
        ]
      });
    }

    // -------------------------------------------------------------
    // 8. Admin Panel APIs
    // -------------------------------------------------------------
    if (req.method === 'GET' && pathname === '/api/admin/users/staff') {
      const staffList = users.filter(u => u.role === 'ROLE_ADMIN' || u.role === 'ROLE_INSPECTOR' || u.role === 'ROLE_CUSTOM_OFFICER');
      return sendJson(200, staffList.map(u => ({
        ...u,
        staffId: u.id,
        firstname: u.fullName ? u.fullName.split(' ')[0] : u.username,
        lastname: u.fullName && u.fullName.split(' ').length > 1 ? u.fullName.split(' ').slice(1).join(' ') : (u.role || '')
      })));
    }

    if (req.method === 'GET' && pathname === '/api/admin/users/drivers') {
      const driverList = users.filter(u => u.role === 'ROLE_DRIVER');
      return sendJson(200, driverList.map(u => ({
        ...u,
        driverId: u.id,
        firstname: u.fullName ? u.fullName.split(' ')[0] : u.username,
        lastname: u.fullName && u.fullName.split(' ').length > 1 ? u.fullName.split(' ').slice(1).join(' ') : 'Driver'
      })));
    }

    if (req.method === 'GET' && pathname === '/api/admin/users/owners') {
      const ownerList = users.filter(u => u.role === 'ROLE_OWNER');
      return sendJson(200, ownerList.map(u => ({
        ...u,
        ownerId: u.id, company: u.companyName || u.company || u.fullName,
        firstname: u.fullName ? u.fullName.split(' ')[0] : u.username,
        lastname: u.fullName && u.fullName.split(' ').length > 1 ? u.fullName.split(' ').slice(1).join(' ') : 'Owner'
      })));
    }

    if (req.method === 'GET' && pathname === '/api/geofences') {
      return sendJson(200, geofences);
    }

    if (req.method === 'GET' && pathname === '/api/admin/audit-logs') {
      return sendJson(200, auditLogs);
    }

    if (req.method === 'POST' && pathname === '/api/admin/users') {
      const newUser = { id: Date.now(), ...jsonBody, active: true };
      users.push(newUser);
      return sendJson(201, newUser);
    }

    if (req.method === 'POST' && pathname === '/api/geofences') {
      const newGeo = { id: Date.now(), ...jsonBody };
      geofences.push(newGeo);
      return sendJson(201, newGeo);
    }

    if (req.method === 'POST' && pathname === '/api/trips/assign') {
      return sendJson(200, { success: true, message: 'Trip successfully assigned' });
    }

    if (req.method === 'POST' && pathname === '/api/alerts/driver-report') {
      alerts.unshift({
        id: alerts.length + 1,
        containerNo: jsonBody.containerNo || 'CONT-LK-001',
        alertType: 'DRIVER_EMERGENCY',
        severity: 'HIGH',
        status: 'PENDING',
        message: jsonBody.message || 'Driver emergency report',
        location: 'In Transit Corridor',
        timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19)
      });
      return sendJson(200, { success: true, message: 'Emergency alert reported' });
    }

    if (req.method === 'DELETE' && pathname.startsWith('/api/users/')) {
      return sendJson(200, { success: true, message: 'User deleted' });
    }

    if (req.method === 'DELETE' && pathname.startsWith('/api/geofences/')) {
      return sendJson(200, { success: true, message: 'Geofence deleted' });
    }

    // Default 200 for any other API routes
    return sendJson(200, { success: true, message: 'OK' });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`SecureTrack SL Backend running at http://localhost:${PORT}`);
});
