package com.follow.clash.service.models

import android.os.Parcelable
import com.follow.clash.common.AccessControlMode
import kotlinx.parcelize.Parcelize
import java.net.InetAddress

@Parcelize
data class AccessControlProps(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
) : Parcelable

@Parcelize
data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val ipv6: Boolean,
    val dnsHijacking: Boolean,
    val accessControlProps: AccessControlProps,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val stack: String,
    val routeAddress: List<String>,
) : Parcelable

data class CIDR(val address: InetAddress, val prefixLength: Int)

fun VpnOptions.getIpv4RouteAddress(): List<CIDR> {
    return routeAddress.filter {
        it.isIpv4()
    }.map {
        it.toCIDR()
    }
}

fun VpnOptions.getIpv6RouteAddress(): List<CIDR> {
    return routeAddress.filter {
        it.isIpv6()
    }.map {
        it.toCIDR()
    }
}

fun String.isIpv4(): Boolean {
    val parts = split("/")
    require(parts.size == 2) { "Invalid CIDR format" }
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 4
}

fun String.isIpv6(): Boolean {
    val parts = split("/")
    require(parts.size == 2) { "Invalid CIDR format" }
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 16
}

fun String.toCIDR(): CIDR {
    val parts = split("/")
    require(parts.size == 2) { "Invalid CIDR format" }
    val ipAddress = parts[0]
    val prefixLength = parts[1].toIntOrNull()
    require(prefixLength != null) { "Invalid prefix length" }

    val address = InetAddress.getByName(ipAddress)

    val maxPrefix = if (address.address.size == 4) 32 else 128
    require(prefixLength in 0..maxPrefix) { "Invalid prefix length for IP version" }

    return CIDR(address, prefixLength)
}
