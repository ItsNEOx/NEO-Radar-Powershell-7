# ░▒▓█ NEO RADAR v1.11 █▓▒░
function Start-NeoRadar {

    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkMagenta
    Write-Host "        ░▒▓█ NEO RADAR v1.11 █▓▒░          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor DarkMagenta
    Write-Host "             Created By ItsNEOx             " -ForegroundColor Magenta
    Write-Host "      The super simple network scanner      " -ForegroundColor DarkCyan
    Write-Host "            for legal purposes              " -ForegroundColor DarkGray
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
    Write-Host ""

    $DefaultPrefix = "192.168.0"
    $CurrentVersion = "1.11"
    $RepoRawUrl = "https://raw.githubusercontent.com/ItsNEOx/Neo-Radar/main/neoradar.ps1"
    $RepoWebUrl = "https://github.com/ItsNEOx/Neo-Radar"

    Write-Host "Choose scan mode:" -ForegroundColor Cyan
    Write-Host "1) Network Ping Scan"
    Write-Host "2) Single Host Inspection (Ports + Hostname + OS)"
    Write-Host "3) Ping + TCP port scan"
    Write-Host "4) ARP Device MAC Lookup & Vendor Identification"
    Write-Host "5) Hostname Scan & Fingerprinting"
    Write-Host "6) Help / Feature Guide"
    Write-Host "7) Check for Updates"
    Write-Host "E) Exit Program"
    Write-Host ""

    $Mode = Read-Host "Enter option number or 'E' to Exit (default: 1)"
    
    if ($Mode -eq 'e' -or $Mode -eq 'E') {
        Write-Host "`nGoodbye." -ForegroundColor Cyan
        exit
    }

    if ([string]::IsNullOrWhiteSpace($Mode)) { $Mode = 1 } else { $Mode = [int]$Mode }

    Write-Host ""

    # -------------------------------------------------------------
    # Mode 6 — Help / Feature Guide
    # -------------------------------------------------------------
    if ($Mode -eq 6) {
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "         NEO RADAR - HELP & GUIDE           " -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host ""
        
        Write-Host "1) Network Ping Scan" -ForegroundColor Yellow
        Write-Host "   Multi-threaded ICMP sweep across a range of IPs to find online hosts." -ForegroundColor Gray
        Write-Host "   Displays live discoveries with round-trip response times (RTT)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "2) Single Host Inspection" -ForegroundColor Yellow
        Write-Host "   In-depth analysis focused on a single IP address." -ForegroundColor Gray
        Write-Host "   Checks Ping response, TTL OS estimation, DNS/LLMNR hostnames," -ForegroundColor Gray
        Write-Host "   and scans key management ports." -ForegroundColor Gray
        Write-Host ""

        Write-Host "3) Ping + TCP Port Scan" -ForegroundColor Yellow
        Write-Host "   Discovers active hosts on the subnet, then attempts fast TCP" -ForegroundColor Gray
        Write-Host "   handshakes against common service ports (FTP, SSH, HTTP/S, SMB, RDP, DBs, etc.)." -ForegroundColor Gray
        Write-Host "   Displays only active/open ports." -ForegroundColor Gray
        Write-Host ""

        Write-Host "4) ARP Device MAC Lookup & Vendor Identification" -ForegroundColor Yellow
        Write-Host "   Queries local network ARP tables to map discovered IP addresses" -ForegroundColor Gray
        Write-Host "   to physical Hardware MAC addresses and identifies the device vendor." -ForegroundColor Gray
        Write-Host ""

        Write-Host "5) Hostname Scan & Fingerprinting" -ForegroundColor Yellow
        Write-Host "   Resolves reverse DNS entries and LLMNR names for subnet devices," -ForegroundColor Gray
        Write-Host "   estimating OS family (Windows, Linux, Cisco) based on ICMP TTL values." -ForegroundColor Gray
        Write-Host ""

        Write-Host "7) Check for Updates" -ForegroundColor Yellow
        Write-Host "   Checks GitHub for new releases and redirects to the web page to download." -ForegroundColor Gray
        Write-Host ""

        Write-Host "General Tip: Enter 'B' or press Enter at prompts to return to the main menu, 'S' to save scan results, or 'E' to exit." -ForegroundColor DarkGray

        Show-EndOptions -SuppressSave
        return
    }

    # -------------------------------------------------------------
    # Mode 7 — Check for Updates
    # -------------------------------------------------------------
    if ($Mode -eq 7) {
        Write-Host "[+] Checking GitHub for updates..." -ForegroundColor Cyan

        try {
            $remoteCode = Invoke-RestMethod -Uri $RepoRawUrl -TimeoutSec 5 -ErrorAction Stop
            $match = [regex]::Match($remoteCode, 'v(\d+\.\d+)')
            
            if ($match.Success) {
                $remoteVersion = $match.Groups[1].Value
                Write-Host "  Current Version: v$CurrentVersion" -ForegroundColor Yellow
                Write-Host "  Latest Version : v$remoteVersion" -ForegroundColor Green

                if ($remoteVersion -ne $CurrentVersion) {
                    Write-Host "`n[!] A new update (v$remoteVersion) is available!" -ForegroundColor Yellow
                    $choice = Read-Host "[+] Would you like to open the GitHub page to download it? (y/N)"
                    if ($choice -eq 'y' -or $choice -eq 'Y') {
                        Write-Host "`n[+] Redirecting to $RepoWebUrl ..." -ForegroundColor Cyan
                        Start-Process $RepoWebUrl
                    }
                } else {
                    Write-Host "`n[+] You are running the latest version!" -ForegroundColor Green
                }
            } else {
                Write-Host "[-] Could not parse version information. Opening GitHub page..." -ForegroundColor Red
                Start-Process $RepoWebUrl
            }
        } catch {
            Write-Host "[-] Could not reach GitHub directly. Opening repository page..." -ForegroundColor Red
            Start-Process $RepoWebUrl
        }

        Show-EndOptions -SuppressSave
        return
    }

    # -------------------------------------------------------------
    # Mode 2 — Single Host Inspection
    # -------------------------------------------------------------
    if ($Mode -eq 2) {
        Write-Host "Enter 'B' for Main Menu, or 'E' to Exit." -ForegroundColor DarkGray
        $TargetIP = Read-Host "Enter target IP address (Example : 192.168.0.1)"

        if ($TargetIP -eq 'e' -or $TargetIP -eq 'E') {
            Write-Host "`nGoodbye." -ForegroundColor Cyan
            exit
        }

        if ([string]::IsNullOrWhiteSpace($TargetIP) -or $TargetIP -eq 'b' -or $TargetIP -eq 'B') {
            Start-NeoRadar
            return
        }

        Write-Host "`n[+] Inspecting single host: $TargetIP..." -ForegroundColor Cyan

        # 1. Quick Ping & TTL Detection
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($TargetIP, 400)
        $ping.Dispose()

        if ($reply.Status -ne "Success") {
            Write-Host "  [-] Host $TargetIP did not respond to ping." -ForegroundColor Yellow
            Show-EndOptions
            return
        }

        Write-Host "  [+] Host Status: ONLINE" -ForegroundColor Green

        # TTL OS Fingerprint
        $ttl = $reply.Options.Ttl
        $os = "Unknown"
        if ($ttl -ge 100 -and $ttl -le 128) { $os = "Windows" }
        elseif ($ttl -ge 32 -and $ttl -le 64) { $os = "Linux / macOS / Mobile" }
        elseif ($ttl -ge 240) { $os = "Cisco / Network Device" }

        # 2. Hostname Resolution
        $hostName = $null
        try { $hostName = [System.Net.Dns]::GetHostEntry($TargetIP).HostName } catch {}

        if (-not $hostName) {
            try {
                $llmnr = Resolve-DnsName -LlmnrOnly -Name $TargetIP -ErrorAction SilentlyContinue
                if ($llmnr) { $hostName = $llmnr.NameHost }
            } catch {}
        }
        if (-not $hostName) { $hostName = "Unavailable" }

        # 3. Port Scan (Most common management & service ports)
        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5900, 8080, 8443)
        $openPorts = @()

        foreach ($port in $Ports) {
            $tcp = New-Object System.Net.Sockets.TcpClient
            try {
                $async = $tcp.BeginConnect($TargetIP, $port, $null, $null)
                if ($async.AsyncWaitHandle.WaitOne(150, $false) -and $tcp.Connected) {
                    $tcp.EndConnect($async)
                    $openPorts += $port
                }
            } catch {} finally { $tcp.Close(); $tcp.Dispose() }
        }

        # Output Results Summary
        Write-Host "`n--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host " Host Details: $TargetIP" -ForegroundColor Cyan
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host "  Hostname : $hostName" -ForegroundColor Green
        Write-Host "  OS Family: $os (TTL: $ttl)" -ForegroundColor Green
        
        $portsText = if ($openPorts.Count -gt 0) { $openPorts -join ', ' } else { "No open ports found" }
        if ($openPorts.Count -gt 0) {
            Write-Host "  Open Ports: $portsText" -ForegroundColor Green
        } else {
            Write-Host "  Open Ports: $portsText" -ForegroundColor DarkGray
        }

        # Assemble scan log for saving
        $scanLog = @(
            "============================================",
            " NEO RADAR - Single Host Inspection Log",
            " Timestamp : $(Get-Date)",
            " Target IP : $TargetIP",
            " Hostname  : $hostName",
            " OS Family : $os (TTL: $ttl)",
            " Open Ports: $portsText",
            "============================================"
        )

        Show-EndOptions -OutputData $scanLog
        return
    }

    # --- Standard Subnet Prompt for Subnet Modes (1, 3, 4, 5) ---
    Write-Host "Enter 'B' for Main Menu, or 'E' to Exit." -ForegroundColor DarkGray
    $PrefixInput = Read-Host "Enter target network prefix (default: $DefaultPrefix)"

    if ($PrefixInput -eq 'e' -or $PrefixInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
    if ($PrefixInput -eq 'b' -or $PrefixInput -eq 'B') { Start-NeoRadar; return }

    $Prefix = if ([string]::IsNullOrWhiteSpace($PrefixInput)) { $DefaultPrefix } else { $PrefixInput }

    $StartInput = Read-Host "Enter starting host number (default: 1)"
    if ($StartInput -eq 'e' -or $StartInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
    if ($StartInput -eq 'b' -or $StartInput -eq 'B') { Start-NeoRadar; return }
    if ([string]::IsNullOrWhiteSpace($StartInput)) { $Start = 1 } else { $Start = [int]$StartInput }

    $EndInput = Read-Host "Enter ending host number (default: 254)"
    if ($EndInput -eq 'e' -or $EndInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
    if ($EndInput -eq 'b' -or $EndInput -eq 'B') { Start-NeoRadar; return }
    if ([string]::IsNullOrWhiteSpace($EndInput)) { $End = 254 } else { $End = [int]$EndInput }

    Write-Host "`n[+] Starting live sweep on $Prefix.$Start through $Prefix.$End..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta

    # --- Real-Time Streaming Subnet Ping Engine ---
    $MaxThreads = 64
    $Pool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
    $Pool.Open()

    $PingScript = {
        param($IP)
        $ping = New-Object System.Net.NetworkInformation.Ping
        try {
            $reply = $ping.Send($IP, 300)
            if ($reply.Status -eq "Success") { 
                return [PSCustomObject]@{ IP = $IP; Status = "ONLINE"; RTT = $reply.RoundtripTime } 
            }
        } catch {} finally { $ping.Dispose() }
        return $null
    }

    $Runspaces = @()
    try {
        for ($i = $Start; $i -le $End; $i++) {
            $TargetIP = "$Prefix.$i"
            $Powershell = [powershell]::Create().AddScript($PingScript).AddArgument($TargetIP)
            $Powershell.RunspacePool = $Pool
            $Runspaces += [PSCustomObject]@{
                Pipe  = $Powershell
                Async = $Powershell.BeginInvoke()
                Done  = $false
            }
        }

        $rawDiscovered = [System.Collections.Generic.List[string]]::new()
        
        # Stream results live as threads complete
        while ($Runspaces | Where-Object { -not $_.Done }) {
            foreach ($r in ($Runspaces | Where-Object { -not $_.Done })) {
                if ($r.Async.IsCompleted) {
                    $r.Done = $true
                    $result = $r.Pipe.EndInvoke($r.Async)
                    $r.Pipe.Dispose()
                    
                    if ($result) {
                        $rawDiscovered.Add($result.IP)
                        Write-Host "  [+] Discovered: $($result.IP) [RTT: $($result.RTT)ms]" -ForegroundColor Green
                    }
                }
            }
            Start-Sleep -Milliseconds 10
        }
    } finally {
        $Pool.Close(); $Pool.Dispose()
    }

    # Sort the discovered IP array numerically by the fourth octet
    $alive = $rawDiscovered | Sort-Object { [int]($_ -split '\.')[3] }

    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
    Write-Host "Sweep Complete. Total Active Hosts: $($alive.Count)" -ForegroundColor Cyan

    if ($alive.Count -eq 0) {
        Write-Host "  [-] No hosts responded." -ForegroundColor Yellow
        Show-EndOptions -OutputData @("No active hosts discovered on $Prefix.$Start-$End")
        return
    }

    # -------------------------------------------------------------
    # Mode 1 — Network Ping Scan
    # -------------------------------------------------------------
    if ($Mode -eq 1) {
        Write-Host "`nSorted Active Hosts:" -ForegroundColor Cyan
        $alive | ForEach-Object { Write-Host "  [+] $_" -ForegroundColor Green }

        $scanLog = @(
            "============================================",
            " NEO RADAR - Network Ping Scan Log",
            " Timestamp : $(Get-Date)",
            " Target    : $Prefix.$Start-$End",
            " Total     : $($alive.Count) active hosts",
            "--------------------------------------------"
        )
        foreach ($h in $alive) { $scanLog += "  [+] $h" }
        $scanLog += "============================================"

        Show-EndOptions -OutputData $scanLog
        return
    }

    # -------------------------------------------------------------
    # Mode 3 — Ping + TCP port scan
    # -------------------------------------------------------------
    if ($Mode -eq 3) {
        Write-Host "`n[+] Scanning common service ports..." -ForegroundColor Cyan

        # Most common Windows & general network service ports
        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5900, 8080, 8443)
        $Pool = [runspacefactory]::CreateRunspacePool(1, 100)
        $Pool.Open()

        $PortScript = {
            param($TargetHost, $TargetPort)
            $tcp = New-Object System.Net.Sockets.TcpClient
            try {
                $async = $tcp.BeginConnect($TargetHost, $TargetPort, $null, $null)
                if ($async.AsyncWaitHandle.WaitOne(150, $false) -and $tcp.Connected) {
                    $tcp.EndConnect($async)
                    return [PSCustomObject]@{ Host=$TargetHost; Port=$TargetPort; Status="OPEN" }
                }
            } catch {} finally { $tcp.Close(); $tcp.Dispose() }
            return $null
        }

        try {
            $TcpRunspaces = @()
            foreach ($target in $alive) {
                foreach ($port in $Ports) {
                    $Powershell = [powershell]::Create().AddScript($PortScript).AddArgument($target).AddArgument($port)
                    $Powershell.RunspacePool = $Pool
                    $TcpRunspaces += [PSCustomObject]@{
                        Pipe  = $Powershell
                        Async = $Powershell.BeginInvoke()
                    }
                }
            }

            $results = foreach ($r in $TcpRunspaces) {
                $res = $r.Pipe.EndInvoke($r.Async)
                $r.Pipe.Dispose()
                if ($res) { $res }
            }
        } finally {
            $Pool.Close(); $Pool.Dispose()
        }

        Write-Host "`nTCP Port Results (Active Ports Only):" -ForegroundColor Cyan
        
        # Sort host output groups numerically
        $grouped = $results | Group-Object Host | Sort-Object { [int]($_.Name -split '\.')[3] }

        $scanLog = @(
            "============================================",
            " NEO RADAR - Ping + TCP Port Scan Log",
            " Timestamp : $(Get-Date)",
            " Target    : $Prefix.$Start-$End",
            "--------------------------------------------"
        )

        foreach ($g in $grouped) {
            $openPortsForHost = $g.Group | Where-Object { $_.Status -eq "OPEN" }
            if ($openPortsForHost) {
                Write-Host "`nHost: $($g.Name)" -ForegroundColor Yellow
                Write-Host "-------------------------" -ForegroundColor DarkMagenta
                $scanLog += "`nHost: $($g.Name)"

                foreach ($r in $openPortsForHost) {
                    Write-Host "  Port $($r.Port) : OPEN" -ForegroundColor Green
                    $scanLog += "  Port $($r.Port) : OPEN"
                }
            } else {
                Write-Host "`nHost: $($g.Name)" -ForegroundColor Yellow
                Write-Host "-------------------------" -ForegroundColor DarkMagenta
                Write-Host "  No open ports found" -ForegroundColor DarkGray
                $scanLog += "`nHost: $($g.Name)"
                $scanLog += "  No open ports found"
            }
        }
        $scanLog += "============================================"

        Show-EndOptions -OutputData $scanLog
        return
    }

    # -------------------------------------------------------------
    # Mode 4 — Fast ARP Device Identification & Vendor Lookup
    # -------------------------------------------------------------
    if ($Mode -eq 4) {
        Write-Host "`n[+] Refreshing local ARP table..." -ForegroundColor Cyan

        $Pool = [runspacefactory]::CreateRunspacePool(1, 64)
        $Pool.Open()
        
        $ArpPing = { 
            param($IP)
            $p = New-Object System.Net.NetworkInformation.Ping
            $p.Send($IP, 150) | Out-Null
            $p.Dispose()
        }

        try {
            foreach ($ip in $alive) {
                $ps = [powershell]::Create().AddScript($ArpPing).AddArgument($ip)
                $ps.RunspacePool = $Pool
                [void]$ps.BeginInvoke()
            }
            Start-Sleep -Milliseconds 250
        } finally {
            $Pool.Close(); $Pool.Dispose()
        }

        $arpOutput = arp -a
        $arpEntries = foreach ($line in $arpOutput) {
            if ($line -match "dynamic") {
                $parts = $line -split "\s+" | Where-Object { $_ }
                [PSCustomObject]@{ IP=$parts[0]; MAC=$parts[1].ToUpper() }
            }
        }

        # Local OUI Lookup dictionary for common vendors (offline speed)
        $OuiTable = @{
            "00:50:56" = "VMware"; "00:0C:29" = "VMware"; "00:05:69" = "VMware"
            "08:00:27" = "Oracle VirtualBox"; "0A:00:27" = "Oracle VirtualBox"
            "B8:27:EB" = "Raspberry Pi"; "D4:3A:04" = "Raspberry Pi"; "E4:5F:01" = "Raspberry Pi"
            "00:1A:11" = "Google"; "3C:5A:B4" = "Google"; "F4:F5:DB" = "Google"
            "00:03:93" = "Apple"; "00:05:02" = "Apple"; "00:0A:27" = "Apple"; "A4:83:E7" = "Apple"
            "00:15:5D" = "Microsoft Hyper-V"; "00:03:FF" = "Microsoft"
            "00:0F:53" = "Dell"; "00:14:22" = "Dell"; "18:66:DA" = "Dell"
            "00:17:A4" = "HP"; "00:1F:29" = "HP"; "3C:D9:2B" = "HP"
            "00:07:0E" = "Cisco"; "00:09:7B" = "Cisco"; "00:1B:0C" = "Cisco"
            "00:11:32" = "Synology"
            "00:04:4B" = "NVIDIA"; "00:04:20" = "Slim Devices / Logitech"
            "00:1E:8C" = "ASUS"; "04:D4:C4" = "ASUS"
            "00:13:E0" = "Cisco Linksys"; "00:14:BF" = "Cisco Linksys"
            "00:14:6C" = "NETGEAR"; "00:18:4D" = "NETGEAR"; "28:80:23" = "NETGEAR"
            "50:C7:BF" = "TP-Link"; "E8:48:B8" = "TP-Link"
            "00:16:6F" = "Intel"; "00:1E:64" = "Intel"; "A4:4E:31" = "Intel"
            "00:12:FB" = "Samsung"; "00:15:99" = "Samsung"; "50:01:D9" = "Samsung"
            "44:65:0D" = "Amazon"; "74:C2:46" = "Amazon"; "A0:02:DC" = "Amazon"
        }

        Write-Host "`nDevice MAC Addresses & Manufacturer Identification:" -ForegroundColor Cyan
        
        $scanLog = @(
            "============================================",
            " NEO RADAR - MAC Lookup & Vendor ID Log",
            " Timestamp : $(Get-Date)",
            " Target    : $Prefix.$Start-$End",
            "--------------------------------------------"
        )

        foreach ($ip in $alive) {
            $entry = $arpEntries | Where-Object { $_.IP -eq $ip }
            if ($entry) {
                $mac = $entry.MAC
                $oui = ($mac -split '[:-]')[0..2] -join ':'
                $vendor = "Unknown Vendor"

                # Check local OUI table first
                if ($OuiTable.ContainsKey($oui)) {
                    $vendor = $OuiTable[$oui]
                } else {
                    # Fallback to online API if internet is available
                    try {
                        $cleanMac = $mac -replace '[:-]', ''
                        $response = Invoke-RestMethod -Uri "https://api.maclookup.app/v2/macs/$cleanMac" -TimeoutSec 2 -ErrorAction SilentlyContinue
                        if ($response -and $response.company) {
                            $vendor = $response.company
                        }
                    } catch {}
                }

                Write-Host "  $ip  ->  $mac  [$vendor]" -ForegroundColor Green
                $scanLog += "  $ip  ->  $mac  [$vendor]"
            } else {
                Write-Host "  $ip  ->  MAC Unavailable" -ForegroundColor DarkGray
                $scanLog += "  $ip  ->  MAC Unavailable"
            }
        }
        $scanLog += "============================================"

        Show-EndOptions -OutputData $scanLog
        return
    }

    # -------------------------------------------------------------
    # Mode 5 — Hostname Scan & Fingerprinting
    # -------------------------------------------------------------
    if ($Mode -eq 5) {
        Write-Host "`n[+] Resolving Hostnames & OS Profiling..." -ForegroundColor Cyan

        $Pool = [runspacefactory]::CreateRunspacePool(1, 32)
        $Pool.Open()

        $HostScript = {
            param($IP)

            $hostName = $null
            try { $hostName = [System.Net.Dns]::GetHostEntry($IP).HostName } catch {}

            if (-not $hostName) {
                try {
                    $llmnr = Resolve-DnsName -LlmnrOnly -Name $IP -ErrorAction SilentlyContinue
                    if ($llmnr) { $hostName = $llmnr.NameHost }
                } catch {}
            }

            $ping = New-Object System.Net.NetworkInformation.Ping
            $reply = $ping.Send($IP, 200)
            $ttl = if ($reply.Status -eq "Success") { $reply.Options.Ttl } else { 0 }
            $ping.Dispose()

            $os = "Unknown"
            if ($ttl -ge 100 -and $ttl -le 128) { $os = "Windows" }
            elseif ($ttl -ge 32 -and $ttl -le 64) { $os = "Linux / macOS / Mobile" }
            elseif ($ttl -ge 240) { $os = "Cisco / Network Device" }

            return [PSCustomObject]@{
                IP       = $IP
                Hostname = if ($hostName) { $hostName } else { "Unavailable" }
                OS       = $os
            }
        }

        try {
            $HostRunspaces = @()
            foreach ($target in $alive) {
                $Powershell = [powershell]::Create().AddScript($HostScript).AddArgument($target)
                $Powershell.RunspacePool = $Pool
                $HostRunspaces += [PSCustomObject]@{
                    Pipe  = $Powershell
                    Async = $Powershell.BeginInvoke()
                }
            }

            $hostResults = foreach ($r in $HostRunspaces) {
                $res = $r.Pipe.EndInvoke($r.Async)
                $r.Pipe.Dispose()
                if ($res) { $res }
            }

            Write-Host "`nHostname & OS Results:" -ForegroundColor Cyan
            $sortedHostResults = $hostResults | Sort-Object { [int]($_.IP -split '\.')[3] }
            
            $scanLog = @(
                "============================================",
                " NEO RADAR - Hostname Scan & Fingerprinting Log",
                " Timestamp : $(Get-Date)",
                " Target    : $Prefix.$Start-$End",
                "--------------------------------------------"
            )

            foreach ($res in $sortedHostResults) {
                Write-Host "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS)" -ForegroundColor Green
                $scanLog += "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS)"
            }
            $scanLog += "============================================"

        } finally {
            $Pool.Close(); $Pool.Dispose()
        }

        Show-EndOptions -OutputData $scanLog
        return
    }

    Show-EndOptions
}

function Show-EndOptions {
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$OutputData,

        [Parameter(Mandatory=$false)]
        [switch]$SuppressSave
    )

    Write-Host ""

    if ($SuppressSave) {
        $action = Read-Host "[+] Press Enter or 'B' for Main Menu, or 'E' to Exit"
    } else {
        $action = Read-Host "[+] Press Enter or 'B' for Main Menu, 'S' to Save Scan, or 'E' to Exit"
    }
    
    if ($action -eq 'e' -or $action -eq 'E') {
        Write-Host "`nGoodbye." -ForegroundColor Cyan
        exit
    } 
    elseif (-not $SuppressSave -and ($action -eq 's' -or $action -eq 'S')) {
        if (-not $OutputData -or $OutputData.Count -eq 0) {
            Write-Host "  [-] No scan results available to save." -ForegroundColor Yellow
        } else {
            $defaultFile = "Scan_Result_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

            # Load Forms assembly for GUI File Dialog
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
            $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
            $saveDialog.FileName = $defaultFile
            $saveDialog.Title = "Select Destination for Scan Results"

            # Trigger Windows GUI File Picker
            if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $filePath = $saveDialog.FileName
                
                try {
                    $OutputData | Out-File -FilePath $filePath -Encoding utf8
                    Write-Host "  [+] Scan results successfully saved to: $filePath" -ForegroundColor Green
                } catch {
                    Write-Host "  [-] Error saving file: $_" -ForegroundColor Red
                }
            } else {
                Write-Host "  [*] Save operation cancelled." -ForegroundColor Yellow
            }
        }
        
        # Re-prompt options after saving or cancelling
        Show-EndOptions -OutputData $OutputData
        return
    } 
    else {
        Start-NeoRadar
    }
}

Start-NeoRadar