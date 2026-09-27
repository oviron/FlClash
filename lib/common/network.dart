import 'dart:io';

extension NetworkInterfaceExt on NetworkInterface {
  bool get isWifi {
    final nameLowCase = name.toLowerCase();
    if (nameLowCase.contains('wlan') ||
        nameLowCase.contains('wi-fi') ||
        nameLowCase == 'en0' ||
        nameLowCase == 'eth0') {
      return true;
    }

    return false;
  }

  bool get includesIPv4 {
    return addresses.any((addr) => addr.isIPv4);
  }
}

extension InternetAddressExt on InternetAddress {
  bool get isIPv4 {
    return type == InternetAddressType.IPv4;
  }

  bool get isPrivateOrReserved {
    if (isLoopback || isLinkLocal || isMulticast) return true;
    final bytes = rawAddress;
    if (isIPv4) return _isReservedIPv4(bytes);
    if (bytes.take(10).every((b) => b == 0) &&
        bytes[10] == 0xff &&
        bytes[11] == 0xff) {
      return _isReservedIPv4(bytes.sublist(12)); // ::ffff:0:0/96
    }
    if (bytes.every((b) => b == 0)) return true; // ::
    if (bytes[0] == 0x20 &&
        bytes[1] == 0x01 &&
        bytes[2] == 0x0d &&
        bytes[3] == 0xb8) {
      return true; // 2001:db8::/32 documentation
    }
    return bytes[0] & 0xfe == 0xfc; // fc00::/7 ULA
  }
}

bool _isReservedIPv4(List<int> bytes) {
  final a = bytes[0], b = bytes[1];
  return a == 0 || // 0.0.0.0/8
      a == 10 || // 10.0.0.0/8
      a == 127 || // 127.0.0.0/8
      a >= 224 || // multicast, 240.0.0.0/4 and broadcast
      (a == 100 && b >= 64 && b <= 127) || // 100.64.0.0/10 CGNAT
      (a == 169 && b == 254) || // 169.254.0.0/16
      (a == 172 && b >= 16 && b <= 31) || // 172.16.0.0/12
      (a == 192 && b == 168) || // 192.168.0.0/16
      (a == 198 && (b == 18 || b == 19)); // 198.18.0.0/15, mihomo fake-ip
}

// Gate for connection-flag lookups: skip domains without a resolved IP,
// private/loopback/link-local/reserved addresses, and unparsable input.
bool shouldLookUpCountryCode(String address) {
  if (address.isEmpty) return false;
  final parsed = InternetAddress.tryParse(address);
  if (parsed == null) return false;
  return !parsed.isPrivateOrReserved;
}
