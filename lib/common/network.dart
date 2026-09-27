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

  // Loopback/link-local/multicast come from dart:io; the private/CGNAT/ULA
  // ranges below are not, so they're checked by hand.
  bool get isPrivateOrReserved {
    if (isLoopback || isLinkLocal || isMulticast) return true;
    final bytes = rawAddress;
    if (isIPv4) {
      if (bytes.every((b) => b == 0)) return true; // 0.0.0.0
      final a = bytes[0], b = bytes[1];
      if (a == 10) return true; // 10.0.0.0/8
      if (a == 172 && b >= 16 && b <= 31) return true; // 172.16.0.0/12
      if (a == 192 && b == 168) return true; // 192.168.0.0/16
      if (a == 100 && b >= 64 && b <= 127) return true; // 100.64.0.0/10 CGNAT
      return false;
    }
    if (bytes.every((b) => b == 0)) return true; // ::
    return bytes[0] & 0xfe == 0xfc; // fc00::/7 ULA
  }
}

// Gate for connection-flag lookups: skip domains without a resolved IP,
// private/loopback/link-local/reserved addresses, and unparsable input.
bool shouldLookUpCountryCode(String address) {
  if (address.isEmpty) return false;
  final parsed = InternetAddress.tryParse(address);
  if (parsed == null) return false;
  return !parsed.isPrivateOrReserved;
}
