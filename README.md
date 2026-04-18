# Network Switch Automated Load Tester (iperf3 + netns)

## Overview
This bash script provides an automated framework for testing physical network switches. Instead of requiring multiple physical hosts to generate traffic, it leverages Linux Network Namespaces (`netns`) to create isolated network stacks on a single machine. It then uses `iperf3` to generate and measure cross-namespace traffic routed through the external hardware switch.

## Architecture & Logic
- **Namespace Isolation:** Creates independent network namespaces to simulate separate physical nodes.
- **Traffic Generation:** Utilizes `iperf3` in server/client modes across the isolated namespaces to stress-test the switch.
- **Hardware Validation:** Measures actual bandwidth and validates the switch's backplane and port configurations under load.

## Current State (Proof of Concept)
This script is currently a PoC/WIP. Core functionality for namespace creation and iperf3 routing is implemented. 
Future iterations may include:
- Automated cleanup of network interfaces.
- Extended reporting and parsing of iperf3 outputs.

## Prerequisites
- Linux OS with `iproute2` (network namespaces support).
- `iperf3` installed.
- 
