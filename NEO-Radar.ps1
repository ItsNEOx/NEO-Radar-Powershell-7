# ░▒▓█ NEO RADAR v1.12 █▓▒░

function Start-NeoRadar {

    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkMagenta# ░▒▓█ NEO RADAR v1.13 █▓▒░

function Start-NeoRadar {

    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkMagenta
    Write-Host "        ░▒▓█ NEO RADAR v1.13 █▓▒░          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor DarkMagenta
    Write-Host "             Created By ItsNEOx             " -ForegroundColor Magenta
    Write-Host "      The super simple network scanner      " -ForegroundColor DarkCyan
    Write-Host "            for legal purposes              " -ForegroundColor DarkGray
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
    Write-Host ""

    $DefaultPrefix = "192.168.0"
    $CurrentVersion = "1.13"
    $RepoRawUrl = "https://raw.githubusercontent.com/ItsNEOx/NEO-Radar-Powershell-7/main/neoradar.ps1"
    $RepoWebUrl = "https://github.com/ItsNEOx/NEO-Radar-Powershell-7"

    # --- Non-Windows detection (this script is Windows-only) ---
    if ($PSVersionTable.PSEdition -eq "Core" -and ($IsLinux -or $IsMacOS)) {
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host " [!] NOT A WINDOWS SYSTEM" -ForegroundColor Yellow
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host " This is a Windows PowerShell script." -ForegroundColor Gray
        Write-Host " It will NOT work on Linux, macOS, or Termux." -ForegroundColor Yellow
        Write-Host " Use the bash version (neoradar) instead." -ForegroundColor Gray
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host ""
    }

    Write-Host "Choose scan mode:" -ForegroundColor Cyan
    Write-Host "1) Network Ping Scan"
    Write-Host "2) Single Host Inspection (Ports + Hostname + OS)"
    Write-Host "3) Ping + TCP port scan"
    Write-Host "4) ARP Device MAC Lookup & Vendor Identification"
    Write-Host "5) Hostname Scan & Fingerprinting"
    Write-Host "6) Help / Feature Guide"
    Write-Host "7) Check for Updates"
    Write-Host "8) Nmap Command Reference"
    Write-Host "E) Exit Program"
    Write-Host ""

    do {
        $Mode = Read-Host "Enter option number or 'E' to Exit (default: 1)"

        if ($Mode -eq 'e' -or $Mode -eq 'E') {
            Write-Host "`nGoodbye." -ForegroundColor Cyan
            exit
        }

        if ([string]::IsNullOrWhiteSpace($Mode)) { $Mode = "1"; break }

        $valid = $Mode -match '^[1-8]$'
        if (-not $valid) {
            Write-Host "  [!] Please enter a number between 1 and 8, or 'E' to exit." -ForegroundColor Yellow
        }
    } while (-not $valid)

    $Mode = [int]$Mode

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
        Write-Host "   handshakes against common service ports." -ForegroundColor Gray
        Write-Host "   All ports scanned per host in a single runspace (batched for speed)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "4) ARP Device MAC Lookup & Vendor Identification" -ForegroundColor Yellow
        Write-Host "   Queries local network ARP tables to map discovered IP addresses" -ForegroundColor Gray
        Write-Host "   to physical Hardware MAC addresses and identifies the device vendor." -ForegroundColor Gray
        Write-Host "   Uses a single broadcast ping to refresh the ARP table (much faster)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "5) Hostname Scan & Fingerprinting" -ForegroundColor Yellow
        Write-Host "   Resolves reverse DNS entries and LLMNR names for subnet devices," -ForegroundColor Gray
        Write-Host "   estimating OS family (Windows, Linux, Cisco) based on ICMP TTL values." -ForegroundColor Gray
        Write-Host ""

        Write-Host "7) Check for Updates" -ForegroundColor Yellow
        Write-Host "   Checks GitHub for new releases and redirects to the web page to download." -ForegroundColor Gray
        Write-Host ""

        Write-Host "8) Nmap Command Reference" -ForegroundColor Yellow
        Write-Host "   Shows the equivalent Nmap commands for each Neo-Radar scan mode," -ForegroundColor Gray
        Write-Host "   with explanations of flags and how each technique works." -ForegroundColor Gray
        Write-Host ""

        Write-Host "Android/Termux Note:" -ForegroundColor Red
        Write-Host "   This is a Windows PowerShell script and will NOT" -ForegroundColor Gray
        Write-Host "   run on Termux or Android terminals." -ForegroundColor Yellow
        Write-Host "   A bash version is included (neoradar) that works" -ForegroundColor Gray
        Write-Host "   on Linux desktop and Termux." -ForegroundColor Gray
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
    # Mode 8 — Nmap Command Reference
    # -------------------------------------------------------------
    if ($Mode -eq 8) {
        Clear-Host
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "       NEO RADAR - Nmap Command Guide       " -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "   How to perform each scan mode with Nmap " -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host ""

        Write-Host "1) Network Ping Scan" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: ICMP sweep across a range of IPs." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sn 192.168.0.0/24" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sn  -> Ping sweep only (no port scan)" -ForegroundColor DarkGray
        Write-Host "     /24  -> CIDR notation for 192.168.0.1-254" -ForegroundColor DarkGray
        Write-Host "   How it works: Sends ICMP echo requests, TCP SYN to port 443," -ForegroundColor Gray
        Write-Host "   TCP ACK to port 80, and ICMP timestamp requests simultaneously." -ForegroundColor Gray
        Write-Host "   Hosts responding to any of these are marked alive." -ForegroundColor Gray
        Write-Host ""

        Write-Host "2) Single Host Inspection" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Ping + TTL OS guess + DNS + port scan on one IP." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -A 192.168.0.1" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -A  -> Aggressive scan (OS detection -O," -ForegroundColor DarkGray
        Write-Host "            version detection -sV, script scanning -sC," -ForegroundColor DarkGray
        Write-Host "            and traceroute --traceroute)" -ForegroundColor DarkGray
        Write-Host "   How it works: Combines multiple Nmap subsystems into" -ForegroundColor Gray
        Write-Host "   one comprehensive scan against a single target." -ForegroundColor Gray
        Write-Host "   Use -p- to scan all 65535 ports (takes much longer)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "3) Ping + TCP Port Scan" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Discover live hosts, then scan common TCP ports." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sS 192.168.0.0/24 -p 21,22,23,25,53,80,110," -ForegroundColor Green
        Write-Host "                     135,139,143,443,445,993,995,1433," -ForegroundColor Green
        Write-Host "                     3306,3389,5900,8080,8443" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sS -> SYN scan (half-open, faster, requires admin/root)" -ForegroundColor DarkGray
        Write-Host "     -sT -> TCP connect scan (no root needed, slower)" -ForegroundColor DarkGray
        Write-Host "     -p  -> Port range or comma-separated list" -ForegroundColor DarkGray
        Write-Host "   How it works: Sends SYN packet; if SYN/ACK comes back," -ForegroundColor Gray
        Write-Host "   port is open. RST indicates closed. No response = filtered." -ForegroundColor Gray
        Write-Host "   On Windows without admin, use -sT instead of -sS." -ForegroundColor Gray
        Write-Host ""

        Write-Host "4) ARP MAC Lookup & Vendor Identification" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Queries local ARP table for MAC addresses." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -PR 192.168.0.0/24" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -PR -> ARP ping (local subnet only, fastest method)" -ForegroundColor DarkGray
        Write-Host "   How it works: Nmap sends ARP requests and reads replies." -ForegroundColor Gray
        Write-Host "   ARP is Layer-2, so it only works on the local subnet." -ForegroundColor Gray
        Write-Host "   It is the fastest and most reliable host discovery method" -ForegroundColor Gray
        Write-Host "   for local networks. To see MACs with a standard scan," -ForegroundColor Gray
        Write-Host "   use: nmap -sn 192.168.0.0/24" -ForegroundColor Gray
        Write-Host "   (MACs appear in the output on the same subnet)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "5) Hostname Scan & Fingerprinting" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: DNS/LLMNR hostname resolution + TTL OS estimate." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sL 192.168.0.0/24    (list scan / DNS lookup)" -ForegroundColor Green
        Write-Host "             nmap -O 192.168.0.0/24     (OS detection)" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sL -> List scan — reverse-DNS resolves all IPs" -ForegroundColor DarkGray
        Write-Host "     -O  -> OS detection (TCP/IP stack fingerprinting)" -ForegroundColor DarkGray
        Write-Host "     --osscan-guess -> Guesses OS more aggressively" -ForegroundColor DarkGray
        Write-Host "   How it works: -sL queries DNS for each IP in range." -ForegroundColor Gray
        Write-Host "   -O analyzes subtle differences in TCP packet responses" -ForegroundColor Gray
        Write-Host "   (initial TTL, window size, DF flag, TCP options order)" -ForegroundColor Gray
        Write-Host "   to fingerprint the operating system with high accuracy." -ForegroundColor Gray
        Write-Host ""

        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host " Quick Reference" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "  -sn       Ping sweep host discovery" -ForegroundColor Green
        Write-Host "  -sS       SYN half-open scan (requires admin)" -ForegroundColor Green
        Write-Host "  -sT       TCP connect scan" -ForegroundColor Green
        Write-Host "  -sV       Service/version detection" -ForegroundColor Green
        Write-Host "  -O        OS fingerprinting" -ForegroundColor Green
        Write-Host "  -sC       Default NSE script scan" -ForegroundColor Green
        Write-Host "  -A        Aggressive (-O -sV -sC --traceroute)" -ForegroundColor Green
        Write-Host "  -PR       ARP ping (local subnet)" -ForegroundColor Green
        Write-Host "  -sL       List scan / DNS resolution" -ForegroundColor Green
        Write-Host "  -p <n>    Port range (e.g. -p 1-1000 or -p- for all)" -ForegroundColor Green
        Write-Host "  -T<0-5>   Timing template (T4 is faster, T5 is insane)" -ForegroundColor Green
        Write-Host "  -v        Increase verbosity" -ForegroundColor Green
        Write-Host "  --reason  Shows why Nmap concluded a port state" -ForegroundColor Green
        Write-Host ""

        Show-EndOptions -SuppressSave
        return
    }

    # -------------------------------------------------------------
    # Mode 2 — Single Host Inspection
    # -------------------------------------------------------------
    if ($Mode -eq 2) {
        while ($true) {
            $TargetIP = Read-Host "Enter target IP address (Example : 192.168.0.1)"

            if ($TargetIP -eq 'e' -or $TargetIP -eq 'E') {
                Write-Host "`nGoodbye." -ForegroundColor Cyan
                exit
            }

            if ($TargetIP -eq 'b' -or $TargetIP -eq 'B') {
                Start-NeoRadar
                return
            }

            if ([string]::IsNullOrWhiteSpace($TargetIP)) {
                Write-Host "  [!] IP address is required." -ForegroundColor Yellow
                continue
            }

            if ($TargetIP -notmatch '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') {
                Write-Host "  [!] Invalid IP format. Use the form 192.168.0.1" -ForegroundColor Yellow
                continue
            }

            $valid = $true
            $octets = $TargetIP -split '\.'
            foreach ($octet in $octets) {
                if ([int]$octet -lt 0 -or [int]$octet -gt 255) {
                    Write-Host "  [!] Each octet must be between 0 and 255." -ForegroundColor Yellow
                    $valid = $false
                    break
                }
            }
            if ($valid) { break }
        }

        Write-Host "`n[+] Inspecting single host: $TargetIP..." -ForegroundColor Cyan

        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($TargetIP, 400)
        $ping.Dispose()

        if ($reply.Status -ne "Success") {
            Write-Host "  [-] Host $TargetIP did not respond to ping." -ForegroundColor Yellow
            Show-EndOptions
            return
        }

        Write-Host "  [+] Host Status: ONLINE" -ForegroundColor Green

        $ttl = $reply.Options.Ttl

        $hostName = $null
        try { $hostName = [System.Net.Dns]::GetHostEntry($TargetIP).HostName } catch {}
        if (-not $hostName) {
            try { $llmnr = Resolve-DnsName -LlmnrOnly -Name $TargetIP -ErrorAction SilentlyContinue; if ($llmnr) { $hostName = $llmnr.NameHost } } catch {}
        }
        if (-not $hostName) { $hostName = "Unavailable" }

        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5000, 5555, 5900, 62078, 8080, 8443)
        $openPorts = @()
        foreach ($port in $Ports) {
            $tcp = New-Object System.Net.Sockets.TcpClient
            try {
                $async = $tcp.BeginConnect($TargetIP, $port, $null, $null)
                if ($async.AsyncWaitHandle.WaitOne(100, $false) -and $tcp.Connected) {
                    $tcp.EndConnect($async)
                    $openPorts += $port
                }
            } catch {} finally { $tcp.Close(); $tcp.Dispose() }
        }

        # --- OS Detection (TTL-based with Apple hostname hint) ---
        if ($ttl -ge 100 -and $ttl -le 128) {
            $os = "Windows"
        } elseif ($ttl -ge 32 -and $ttl -le 64) {
            $os = "Linux / Unix / Android / macOS"
        } elseif ($ttl -ge 240) {
            $os = "Network / IoT Device"
        } else {
            $os = "Unknown"
        }

        # Apple override via hostname
        if ($hostName) {
            $h = $hostName.ToUpper()
            if ($h -match '^IPHONE|^IPAD|^IPOD') { $os = "Apple iOS" }
            elseif ($h -match '^MACBOOK|^MAC-PRO|^IMAC|^MACMINI|^MAC-') { $os = "Apple macOS" }
        }

        $pct = 100
        $confidence = "medium"

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

        $scanLog = @(
            "============================================",
            " NEO RADAR - Single Host Inspection Log",
            " Timestamp : $(Get-Date)",
            " Target IP : $TargetIP",
            " Hostname  : $hostName",
            " OS Family : $os (TTL: $ttl, confidence: $confidence)",
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

    do {
        $StartInput = Read-Host "Enter starting host number (1-255, default: 1)"
        if ($StartInput -eq 'e' -or $StartInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
        if ($StartInput -eq 'b' -or $StartInput -eq 'B') { Start-NeoRadar; return }
        if ([string]::IsNullOrWhiteSpace($StartInput)) { $Start = 1; break }
        if ($StartInput -notmatch '^(?:[1-9]|[12]\d|25[0-5])$') {
            Write-Host "  [!] Numbers only, between 1 and 255." -ForegroundColor Yellow
            $valid = $false
        } else {
            $Start = [int]$StartInput; break
        }
    } while ($true)

    do {
        $EndInput = Read-Host "Enter ending host number (1-255, default: 254)"
        if ($EndInput -eq 'e' -or $EndInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
        if ($EndInput -eq 'b' -or $EndInput -eq 'B') { Start-NeoRadar; return }
        if ([string]::IsNullOrWhiteSpace($EndInput)) { $End = 254; break }
        if ($EndInput -notmatch '^(?:[1-9]|[12]\d|25[0-5])$') {
            Write-Host "  [!] Numbers only, between 1 and 255." -ForegroundColor Yellow
        } else {
            $End = [int]$EndInput; break
        }
    } while ($true)

    if ($Start -gt $End) {
        Write-Host "  [!] Starting host cannot be greater than ending host." -ForegroundColor Yellow
        Start-NeoRadar
        return
    }

    Write-Host "`n[+] Starting live sweep on $Prefix.$Start through $Prefix.$End..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta

    # --- Optimized Ping Engine (WaitHandle-based completion, no busy-poll) ---
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
            }
        }

        # Stream completions using IsCompleted (no Where-Object overhead per iteration)
        $rawDiscovered = [System.Collections.Generic.List[string]]::new()
        $pending = $Runspaces.Count

        while ($pending -gt 0) {
            for ($i = 0; $i -lt $Runspaces.Count; $i++) {
                $r = $Runspaces[$i]
                if ($r -and $r.Async.IsCompleted) {
                    $Runspaces[$i] = $null
                    $pending--
                    $result = $r.Pipe.EndInvoke($r.Async)
                    $r.Pipe.Dispose()
                    if ($result) {
                        $rawDiscovered.Add($result.IP)
                        Write-Host "  [+] Discovered: $($result.IP) [RTT: $($result.RTT)ms]" -ForegroundColor Green
                    }
                }
            }
            if ($pending -gt 0) { Start-Sleep -Milliseconds 50 }
        }
    } finally {
        $Pool.Close(); $Pool.Dispose()
    }

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
    # Mode 3 — Ping + TCP port scan (BATCHED: all ports per runspace)
    # -------------------------------------------------------------
    if ($Mode -eq 3) {
        Write-Host "`n[+] Scanning common service ports..." -ForegroundColor Cyan

        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5900, 8080, 8443)
        $Pool = [runspacefactory]::CreateRunspacePool(1, 64)
        $Pool.Open()

        $PortScript = {
            param($TargetHost, $Ports)
            $open = @()
            foreach ($port in $Ports) {
                $tcp = New-Object System.Net.Sockets.TcpClient
                try {
                    $async = $tcp.BeginConnect($TargetHost, $port, $null, $null)
                    if ($async.AsyncWaitHandle.WaitOne(100, $false) -and $tcp.Connected) {
                        $tcp.EndConnect($async)
                        $open += $port
                    }
                } catch {} finally { $tcp.Close(); $tcp.Dispose() }
            }
            return [PSCustomObject]@{ Host = $TargetHost; OpenPorts = $open }
        }

        try {
            $TcpRunspaces = @()
            foreach ($target in $alive) {
                $Powershell = [powershell]::Create().AddScript($PortScript).AddArgument($target).AddArgument($Ports)
                $Powershell.RunspacePool = $Pool
                $TcpRunspaces += [PSCustomObject]@{
                    Pipe  = $Powershell
                    Async = $Powershell.BeginInvoke()
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

        $grouped = $results | Group-Object Host | Sort-Object { [int]($_.Name -split '\.')[3] }

        $scanLog = @(
            "============================================",
            " NEO RADAR - Ping + TCP Port Scan Log",
            " Timestamp : $(Get-Date)",
            " Target    : $Prefix.$Start-$End",
            "--------------------------------------------"
        )

        foreach ($g in $grouped) {
            $allPorts = $g.Group[0].OpenPorts
            if ($allPorts -and $allPorts.Count -gt 0) {
                Write-Host "`nHost: $($g.Name)" -ForegroundColor Yellow
                Write-Host "-------------------------" -ForegroundColor DarkMagenta
                $scanLog += "`nHost: $($g.Name)"
                foreach ($p in $allPorts) {
                    Write-Host "  Port $p : OPEN" -ForegroundColor Green
                    $scanLog += "  Port $p : OPEN"
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
    # Mode 4 — Fast ARP Device Identification (single broadcast ping)
    # -------------------------------------------------------------
    if ($Mode -eq 4) {
        Write-Host "`n[+] Refreshing local ARP table with broadcast ping..." -ForegroundColor Cyan

        $broadcast = "$Prefix.255"
        $ping = New-Object System.Net.NetworkInformation.Ping
        $ping.Send($broadcast, 200) | Out-Null
        $ping.Dispose()
        Start-Sleep -Milliseconds 300

        $arpOutput = arp -a
        $arpEntries = foreach ($line in $arpOutput) {
            if ($line -match "dynamic") {
                $parts = $line -split "\s+" | Where-Object { $_ }
                if ($parts.Count -ge 2) {
                    [PSCustomObject]@{ IP = $parts[0]; MAC = $parts[1].ToUpper() }
                }
            }
        }

        $macCache = @{
            # --- Virtualization ---
            "00:50:56" = "VMware"; "00:0C:29" = "VMware"; "00:05:69" = "VMware"
            "08:00:27" = "Oracle VirtualBox"; "0A:00:27" = "Oracle VirtualBox"
            "00:15:5D" = "Microsoft Hyper-V"; "00:03:FF" = "Microsoft"
            "00:16:3E" = "Xen / Citrix"; "00:0E:0C" = "Xen / Citrix"
            "52:54:00" = "QEMU/KVM (user)"
            # --- Single Board Computers ---
            "B8:27:EB" = "Raspberry Pi"; "D4:3A:04" = "Raspberry Pi"
            "E4:5F:01" = "Raspberry Pi"; "2C:CF:67" = "Raspberry Pi"
            "DC:A6:32" = "Raspberry Pi"; "00:13:C3" = "Arduino"
            "98:BA:61" = "BeagleBoard"; "A0:20:A6" = "Odroid"
            # --- Apple ---
            "00:03:93" = "Apple"; "00:05:02" = "Apple"; "00:0A:27" = "Apple"
            "00:0D:93" = "Apple"; "00:11:24" = "Apple"; "00:14:51" = "Apple"
            "00:16:CB" = "Apple"; "00:17:F2" = "Apple"; "00:19:E3" = "Apple"
            "00:1B:63" = "Apple"; "00:1D:4F" = "Apple"; "00:1E:52" = "Apple"
            "00:1F:5B" = "Apple"; "00:1F:F3" = "Apple"; "00:21:E9" = "Apple"
            "00:22:41" = "Apple"; "00:23:32" = "Apple"; "00:23:6C" = "Apple"
            "00:24:36" = "Apple"; "00:25:00" = "Apple"; "00:25:BC" = "Apple"
            "00:26:08" = "Apple"; "00:26:B0" = "Apple"; "00:50:E4" = "Apple"
            "04:0C:CE" = "Apple"; "08:66:98" = "Apple"; "0C:30:21" = "Apple"
            "0C:74:C2" = "Apple"; "10:93:E9" = "Apple"; "10:9A:DD" = "Apple"
            "14:7D:DA" = "Apple"; "18:5A:F6" = "Apple"; "1C:5B:47" = "Apple"
            "2C:BE:EB" = "Apple"; "34:15:9E" = "Apple"; "34:A3:95" = "Apple"
            "3C:07:54" = "Apple"; "3C:D0:F8" = "Apple"; "40:A5:EF" = "Apple"
            "44:2E:E6" = "Apple"; "44:4E:6A" = "Apple"; "48:60:5F" = "Apple"
            "48:8E:EC" = "Apple"; "4C:32:75" = "Apple"; "54:E4:3A" = "Apple"
            "58:55:CA" = "Apple"; "60:33:4B" = "Apple"; "60:8C:4A" = "Apple"
            "64:76:F0" = "Apple"; "64:A2:F9" = "Apple"; "68:5B:36" = "Apple"
            "68:AB:7E" = "Apple"; "6C:72:E7" = "Apple"; "70:3E:AC" = "Apple"
            "78:4B:7F" = "Apple"; "78:4F:43" = "Apple"; "7C:04:D0" = "Apple"
            "7C:11:BE" = "Apple"; "80:BE:05" = "Apple"; "84:38:38" = "Apple"
            "88:53:2C" = "Apple"; "8C:7B:9D" = "Apple"; "8C:85:90" = "Apple"
            "90:84:0D" = "Apple"; "94:DB:49" = "Apple"; "98:01:A7" = "Apple"
            "98:FE:94" = "Apple"; "A0:99:9B" = "Apple"; "A4:6B:6B" = "Apple"
            "A4:83:E7" = "Apple"; "A8:86:DD" = "Apple"; "AC:29:3A" = "Apple"
            "B0:65:BD" = "Apple"; "B4:F0:AB" = "Apple"; "B8:E8:56" = "Apple"
            "BC:92:6B" = "Apple"; "C0:FE:45" = "Apple"; "C4:2B:2C" = "Apple"
            "C8:4C:75" = "Apple"; "CC:08:FB" = "Apple"; "CC:20:E8" = "Apple"
            "D0:3A:05" = "Apple"; "D4:06:7B" = "Apple"; "D4:61:FE" = "Apple"
            "D8:9A:34" = "Apple"; "DC:2B:66" = "Apple"; "E0:1E:34" = "Apple"
            "E0:F8:47" = "Apple"; "E4:CE:8F" = "Apple"; "E8:FD:CE" = "Apple"
            "F0:18:98" = "Apple"; "F0:4F:7C" = "Apple"; "F0:9A:51" = "Apple"
            "F4:0F:24" = "Apple"; "F4:F5:DB" = "Apple"; "FC:E9:98" = "Apple"
            "F8:1E:DF" = "Apple"; "FC:25:3F" = "Apple"
            # --- Google ---
            "00:1A:11" = "Google"; "3C:5A:B4" = "Google"; "DA:A1:19" = "Google"
            "A4:77:33" = "Google"; "D0:52:A8" = "Google"
            "38:5B:0B" = "Google"; "38:5B:0C" = "Google"
            "8C:5C:3A" = "Google (Chromecast)"; "8C:B8:4A" = "Google"
            "F8:DF:A8" = "Google"; "B4:3A:28" = "Google"
            "9C:AD:EF" = "Google"; "00:18:0A" = "Google"
            # --- Samsung ---
            "00:12:FB" = "Samsung"; "00:15:99" = "Samsung"; "50:01:D9" = "Samsung"
            "B0:5C:DA" = "Samsung"; "EC:1F:72" = "Samsung"
            "F0:27:2B" = "Samsung"; "94:5E:2B" = "Samsung"
            "70:85:C2" = "Samsung"; "5C:51:4F" = "Samsung"
            "C8:94:02" = "Samsung"; "F8:2C:18" = "Samsung"
            "8C:FB:A5" = "Samsung"; "A4:90:05" = "Samsung"
            "20:D9:06" = "Samsung"
            # --- Amazon ---
            "44:65:0D" = "Amazon"; "74:C2:46" = "Amazon"; "A0:02:DC" = "Amazon"
            "64:00:6A" = "Amazon"; "4C:EF:C0" = "Amazon"
            "40:B0:76" = "Amazon"; "AC:63:BE" = "Amazon"
            # --- Dell ---
            "00:0F:53" = "Dell"; "00:14:22" = "Dell"; "18:66:DA" = "Dell"
            "00:12:3F" = "Dell"; "00:1D:09" = "Dell"; "00:21:70" = "Dell"
            "00:24:E8" = "Dell"; "5C:F9:DD" = "Dell"; "F8:DB:7F" = "Dell"
            # --- HP ---
            "00:17:A4" = "HP"; "00:1F:29" = "HP"; "3C:D9:2B" = "HP"
            "00:1A:4B" = "HP"; "00:23:7D" = "HP"; "00:25:B3" = "HP"
            "38:63:BB" = "HP"; "2C:59:8A" = "HP"; "9C:AE:D3" = "HP"
            # --- Lenovo / IBM ---
            "00:14:85" = "Lenovo / IBM"; "00:1E:37" = "Lenovo / IBM"
            "00:21:6A" = "Lenovo / IBM"; "00:24:51" = "Lenovo / IBM"
            "E0:96:FB" = "Lenovo / IBM"
            # --- ASUS ---
            "00:1E:8C" = "ASUS"; "04:D4:C4" = "ASUS"; "10:BF:48" = "ASUS"
            "1C:87:2C" = "ASUS"; "24:F0:94" = "ASUS"; "3C:06:30" = "ASUS"
            "60:A4:4C" = "ASUS"; "74:D0:2B" = "ASUS"; "8C:10:D4" = "ASUS"
            "94:D9:B3" = "ASUS"; "A0:21:B7" = "ASUS"; "B0:6E:BF" = "ASUS"
            "C8:1E:E7" = "ASUS"; "E8:9F:6D" = "ASUS"
            # --- Acer ---
            "00:1B:24" = "Acer"; "00:1F:C6" = "Acer"; "1C:6F:65" = "Acer"
            "78:24:AF" = "Acer"; "98:4B:4A" = "Acer"; "D4:38:9C" = "Acer"
            # --- Cisco ---
            "00:00:0C" = "Cisco"; "00:01:43" = "Cisco"; "00:01:96" = "Cisco"
            "00:07:0E" = "Cisco"; "00:09:7B" = "Cisco"; "00:1B:0C" = "Cisco"
            "00:1A:A1" = "Cisco"; "00:1E:7A" = "Cisco"; "00:1D:46" = "Cisco"
            "0C:27:24" = "Cisco"; "1C:DE:A7" = "Cisco"; "24:16:6D" = "Cisco"
            "3C:CE:73" = "Cisco"; "54:7F:EE" = "Cisco"; "5C:50:15" = "Cisco"
            "64:16:7F" = "Cisco"; "6C:88:14" = "Cisco"; "84:8F:69" = "Cisco"
            "A0:1D:48" = "Cisco"; "A0:52:8A" = "Cisco"; "B0:6C:BF" = "Cisco"
            "C4:6A:CF" = "Cisco"; "D8:F2:CA" = "Cisco"; "E0:2D:E6" = "Cisco"
            # --- TP-Link ---
            "50:C7:BF" = "TP-Link"; "E8:48:B8" = "TP-Link"; "00:1D:0F" = "TP-Link"
            "98:DA:C4" = "TP-Link"; "54:A0:50" = "TP-Link"; "64:66:B3" = "TP-Link"
            "70:4C:A5" = "TP-Link"; "98:0D:2E" = "TP-Link"; "B0:BE:76" = "TP-Link"
            "F4:EC:38" = "TP-Link"; "84:D8:1B" = "TP-Link"; "1C:3B:F3" = "TP-Link"
            "10:FE:ED" = "TP-Link"; "00:0E:2E" = "TP-Link"
            # --- NETGEAR ---
            "00:14:6C" = "NETGEAR"; "00:18:4D" = "NETGEAR"; "28:80:23" = "NETGEAR"
            "A4:2B:8C" = "NETGEAR"; "38:22:D6" = "NETGEAR"; "80:35:C1" = "NETGEAR"
            "20:F4:1B" = "NETGEAR"; "C0:3F:0E" = "NETGEAR"; "84:1B:5E" = "NETGEAR"
            "B0:39:56" = "NETGEAR"; "A0:D3:C1" = "NETGEAR"
            # --- Linksys ---
            "00:12:17" = "Linksys"; "00:14:BF" = "Linksys"; "00:18:39" = "Linksys"
            "00:1C:10" = "Linksys"; "00:1A:70" = "Linksys"; "00:22:6B" = "Linksys"
            "00:25:9C" = "Linksys"; "00:23:69" = "Linksys"; "E0:91:F5" = "Linksys"
            # --- D-Link ---
            "00:05:5D" = "D-Link"; "00:0D:88" = "D-Link"; "00:11:95" = "D-Link"
            "00:15:E9" = "D-Link"; "00:1B:11" = "D-Link"; "00:1C:F0" = "D-Link"
            "28:10:7B" = "D-Link"; "74:DA:DA" = "D-Link"; "B0:C5:54" = "D-Link"
            "CC:B2:55" = "D-Link"; "1C:91:80" = "D-Link"
            # --- Ubiquiti ---
            "00:15:6D" = "Ubiquiti"; "00:27:22" = "Ubiquiti"; "04:18:D6" = "Ubiquiti"
            "24:A4:2C" = "Ubiquiti"; "44:D9:E7" = "Ubiquiti"; "68:72:51" = "Ubiquiti"
            "74:83:C2" = "Ubiquiti"; "78:8A:20" = "Ubiquiti"; "D0:21:4F" = "Ubiquiti"
            "E0:63:DA" = "Ubiquiti"
            # --- MikroTik ---
            "00:0E:8F" = "MikroTik"; "4C:5F:70" = "MikroTik"; "64:D1:54" = "MikroTik"
            "A8:40:41" = "MikroTik"; "D4:CA:6D" = "MikroTik"; "E4:8D:8C" = "MikroTik"
            # --- Huawei ---
            "00:18:82" = "Huawei"; "00:25:9E" = "Huawei"; "3C:5C:1C" = "Huawei"
            "4C:7F:62" = "Huawei"; "54:07:CC" = "Huawei"; "70:B3:D5" = "Huawei"
            "74:39:EA" = "Huawei"; "8C:3C:4A" = "Huawei"; "C0:25:06" = "Huawei"
            "F8:0D:43" = "Huawei"
            # --- Xiaomi ---
            "00:0F:90" = "Xiaomi"; "18:2B:0A" = "Xiaomi"; "38:BA:F8" = "Xiaomi"
            "48:FD:8E" = "Xiaomi"; "54:9F:13" = "Xiaomi"; "8C:34:FD" = "Xiaomi"
            "90:0D:CB" = "Xiaomi"; "C0:EE:FB" = "Xiaomi"; "E0:AC:CB" = "Xiaomi"
            # --- Synology ---
            "00:11:32" = "Synology"; "00:12:7B" = "Synology"
            # --- QNAP ---
            "00:08:9B" = "QNAP"; "00:1A:CE" = "QNAP"
            # --- Western Digital ---
            "00:1D:EC" = "Western Digital"; "00:90:A9" = "Western Digital"
            "18:26:CB" = "Western Digital"
            # --- Intel ---
            "00:16:6F" = "Intel"; "00:1E:64" = "Intel"; "A4:4E:31" = "Intel"
            "00:1B:21" = "Intel"; "00:1C:C0" = "Intel"; "00:21:85" = "Intel"
            "F4:6D:04" = "Intel"; "54:EE:75" = "Intel"
            # --- Realtek ---
            "00:E0:4C" = "Realtek"; "00:E0:18" = "Realtek"
            # --- Broadcom ---
            "00:10:18" = "Broadcom"; "00:0A:F7" = "Broadcom"
            "20:68:7D" = "Broadcom"
            # --- NVIDIA ---
            "00:04:4B" = "NVIDIA"; "10:02:B5" = "NVIDIA"
            # --- Sony ---
            "00:0B:46" = "Sony"; "00:1D:BA" = "Sony"; "00:21:5D" = "Sony"
            "08:12:CF" = "Sony"; "D8:47:BB" = "Sony"; "70:66:55" = "Sony"
            # --- LG ---
            "00:1E:66" = "LG"; "00:22:44" = "LG"; "A8:B8:E0" = "LG"
            "DC:33:0D" = "LG"; "E0:CB:4E" = "LG"
            # --- Nintendo ---
            "00:19:FD" = "Nintendo"; "00:22:AA" = "Nintendo"; "A4:C0:E1" = "Nintendo"
            "B4:7C:9C" = "Nintendo"; "B8:27:6D" = "Nintendo"
            # --- Microsoft Xbox ---
            "00:22:48" = "Microsoft Xbox"; "58:47:CA" = "Microsoft Xbox"
            "7C:1E:52" = "Microsoft Xbox"; "A4:5E:60" = "Microsoft Xbox"
            # --- Sony PlayStation ---
            "00:04:20" = "Sony Interactive / Logitech"; "00:1F:E1" = "Sony PlayStation"
            "A8:93:52" = "Sony PlayStation"; "00:26:5C" = "Sony Interactive"
            # --- Roku ---
            "00:0D:4B" = "Roku"; "0C:A6:13" = "Roku"; "28:E7:CF" = "Roku"

            # --- Brother Printers ---
            "00:0D:D9" = "Brother"; "00:1B:8C" = "Brother"; "00:23:05" = "Brother"
            "00:25:77" = "Brother"; "04:A3:16" = "Brother"; "10:23:32" = "Brother"
            # --- Canon Printers ---
            "00:0A:99" = "Canon"; "00:1B:7A" = "Canon"
            # --- HP Printers ---
            "00:0B:CD" = "HP"; "00:1E:4F" = "HP"; "00:21:5A" = "HP"
            # --- Epson ---
            "00:00:48" = "Epson"; "00:0C:6E" = "Epson"; "00:1B:E2" = "Epson"
            # --- Philips Hue ---
            "00:17:88" = "Philips Hue"; "EC:B5:FA" = "Philips Hue"
            # --- Sonos ---
            "00:0E:58" = "Sonos"; "B8:E9:37" = "Sonos"; "94:59:9C" = "Sonos"
            # --- Ring ---
            "00:0E:C2" = "Ring / Amazon"; "74:75:48" = "Ring / Amazon"
            # --- NetApp ---
            "00:0A:98" = "NetApp"
            # --- Juniper ---
            "00:1A:BD" = "Juniper"; "00:12:1E" = "Juniper"
            # --- Hewlett Packard Enterprise (Aruba) ---
            "00:1A:1E" = "Aruba / HPE"; "B0:B9:8A" = "Aruba / HPE"
            "D0:C7:C0" = "Aruba / HPE"
            # --- Fortinet ---
            "00:09:0F" = "Fortinet"; "90:6C:AC" = "Fortinet"
            "BC:16:65" = "Fortinet"
            # --- Zyxel ---
            "00:13:49" = "Zyxel"; "00:1A:CF" = "Zyxel"; "1C:1D:86" = "Zyxel"
            # --- OnePlus ---
            "0A:0B:0C" = "OnePlus"; "DA:AE:C7" = "OnePlus"
            # --- Motorola ---
            "00:1E:0B" = "Motorola"; "1C:2B:10" = "Motorola"
            "2C:5B:1A" = "Motorola"; "00:15:0C" = "Motorola"
            # --- Nokia ---
            "00:13:7A" = "Nokia"; "00:22:A2" = "Nokia"
            "4C:6B:39" = "Nokia"; "B0:A7:37" = "Nokia"
            # --- HTC ---
            "00:12:D2" = "HTC"; "00:0B:FC" = "HTC"
            "28:D0:EA" = "HTC"; "10:2D:B6" = "HTC"
            # --- BlackBerry ---
            "00:0A:28" = "BlackBerry"; "00:1F:DD" = "BlackBerry"
            # --- Oppo / Vivo / Realme ---
            "7C:61:0E" = "Oppo"; "8C:50:85" = "Oppo"
            "9C:FC:E8" = "Oppo"; "44:77:33" = "Vivo"
            # --- Wyze ---
            "24:CF:21" = "Wyze Labs"; "2C:AA:8E" = "Wyze Labs"
            # --- Belkin / WeMo ---
            "00:1D:7D" = "Belkin / WeMo"; "EC:1A:59" = "Belkin / WeMo"
            # --- Ecobee ---
            "50:2F:A5" = "Ecobee"
            # --- Arlo ---
            "14:EB:B6" = "Arlo / Netgear"
            # --- Honeywell ---
            "00:1A:AF" = "Honeywell"
            # --- Vizio ---
            "00:1E:C9" = "Vizio"; "B0:09:1A" = "Vizio"
            # --- TCL ---
            "6C:AD:EF" = "TCL"; "9C:EF:D5" = "TCL"
            # --- Hisense ---
            "00:23:4E" = "Hisense"; "64:1A:22" = "Hisense"
            # --- Lutron ---
            "00:18:2E" = "Lutron"
            # --- August Home ---
            "34:EA:34" = "August Home"
            # --- Tuya / Smart Life (IoT) ---
            "10:D6:1B" = "Tuya Smart"; "4C:11:BF" = "Tuya Smart"; "84:E3:42" = "Tuya Smart"
            # --- eero ---
            "8C:6B:8F" = "eero"
            # --- Orbi ---
            "1C:61:B4" = "Orbi / Netgear"
            # --- Plume ---
            "BC:2C:2D" = "Plume"
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

                # Check for randomized/private MAC (mobile privacy feature)
                $firstOctet = $mac -split '[:-]' | Select-Object -First 1
                $secondChar = $firstOctet[1]
                if ($secondChar -match '[26AE]') {
                    $vendor = "Randomized MAC (Privacy)"
                } else {
                    # Check cache first (built-in + previously fetched)
                    if ($macCache.ContainsKey($oui)) {
                        $vendor = $macCache[$oui]
                    } else {
                        # Fetch from API and cache for future lookups
                        try {
                            $cleanMac = $mac -replace '[:-]', ''
                            $response = Invoke-RestMethod -Uri "https://api.maclookup.app/v2/macs/$cleanMac" -TimeoutSec 3 -ErrorAction SilentlyContinue
                            if ($response -and $response.company) {
                                $vendor = $response.company
                                $macCache[$oui] = $vendor
                            }
                        } catch {}
                    }
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

            # --- Multi-method hostname resolution ---
            $hostName = $null
            try { $hostName = [System.Net.Dns]::GetHostEntry($IP).HostName } catch {}

            if (-not $hostName) {
                try {
                    $ptr = Resolve-DnsName -Name $IP -Type PTR -ErrorAction SilentlyContinue
                    if ($ptr) { $hostName = $ptr.NameHost }
                } catch {}
            }

            if (-not $hostName) {
                try {
                    $llmnr = Resolve-DnsName -LlmnrOnly -Name $IP -ErrorAction SilentlyContinue
                    if ($llmnr) { $hostName = $llmnr.NameHost }
                } catch {}
            }

            # --- NetBIOS name (Windows hosts) ---
            $netbiosName = $null
            try {
                $nbt = nbtstat -A $IP 2>$null
                if ($nbt) {
                    $lines = $nbt | Select-String "<00>" | Where-Object { $_ -notmatch "<GROUP>" }
                    if ($lines) {
                        $netbiosName = ($lines[0] -split '\s+')[0]
                        if (-not $hostName) { $hostName = $netbiosName }
                    }
                }
            } catch {}

            # --- ICMP ping + TTL ---
            $ttl = 0
            $ping = New-Object System.Net.NetworkInformation.Ping
            try {
                $reply = $ping.Send($IP, 200)
                if ($reply.Status -eq "Success") { $ttl = $reply.Options.Ttl }
            } catch {} finally { $ping.Dispose() }

            # --- Key port probing (fast asynchronous) ---
            $keyPorts = @(22, 23, 80, 139, 443, 445, 3389, 5000, 5555, 62078)
            $openPorts = @()
            foreach ($port in $keyPorts) {
                $tcp = New-Object System.Net.Sockets.TcpClient
                try {
                    $async = $tcp.BeginConnect($IP, $port, $null, $null)
                    if ($async.AsyncWaitHandle.WaitOne(40, $false) -and $tcp.Connected) {
                        $tcp.EndConnect($async)
                        $openPorts += $port
                    }
                } catch {} finally { $tcp.Close(); $tcp.Dispose() }
            }

            # --- HTTP banner grab on port 80 ---
            $serverHeader = $null
            if ($openPorts -contains 80) {
                try {
                    $req = [System.Net.WebRequest]::Create("http://$IP/")
                    $req.Timeout = 2000
                    $resp = $req.GetResponse()
                    $serverHeader = $resp.Headers["Server"]
                    $resp.Close()
                } catch {}
            }

            # --- Combined multi-signal OS scoring ---
            $scores = @{ Windows = 0; Linux = 0; Apple = 0; Network = 0 }

            # TTL
            if ($ttl -ge 100 -and $ttl -le 128) { $scores.Windows += 2 }
            elseif ($ttl -ge 32 -and $ttl -le 64) { $scores.Linux += 2 }
            elseif ($ttl -ge 240 -and $ttl -le 255) { $scores.Network += 2 }

            # Hostname clues
            if ($hostName) {
                $h = $hostName.ToUpper()
                if ($h -match '^IPHONE|^IPAD|^IPOD') { $scores.Apple += 3 }
                if ($h -match '^MACBOOK|^MAC-PRO|^IMAC|^MACMINI') { $scores.Apple += 3 }
                if ($h -match '^ANDROID|^SM-|^GT-|^REDMI|^POCO|^MOTO') { $scores.Linux += 2 }
            }

            # Port evidence
            if ($openPorts -contains 445) { $scores.Windows += 3 }
            if ($openPorts -contains 139) { $scores.Windows += 2 }
            if ($openPorts -contains 3389) { $scores.Windows += 2 }
            if ($openPorts -contains 22) { $scores.Linux += 2 }
            if ($openPorts -contains 23) { $scores.Network += 1 }
            if ($openPorts -contains 5000) { $scores.Apple += 3 }
            if ($openPorts -contains 62078) { $scores.Apple += 2 }
            if ($openPorts -contains 5555) { $scores.Linux += 2 }

            # HTTP server header
            if ($serverHeader) {
                if ($serverHeader -match "Microsoft-IIS") { $scores.Windows += 2 }
                elseif ($serverHeader -match "Apache|nginx") { $scores.Linux += 1 }
            }

            # NetBIOS name is strongly Windows
            if ($netbiosName) { $scores.Windows += 3 }

            # MAC OUI hint (weak, +1 only)
            try {
                $arpEntry = arp -a | Select-String $IP | Select-Object -First 1
                if ($arpEntry) {
                    $macLine = $arpEntry -split "\s+" | Where-Object { $_ -match "^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$" } | Select-Object -First 1
                    if ($macLine) {
                        $oui = ($macLine.ToUpper() -split '[:-]')[0..2] -join ':'
                        $appleOuics = @("00:03:93","00:05:02","00:0A:27","10:93:E9","A4:83:E7","F4:F5:DB","14:7D:DA","18:5A:F6","34:A3:95","3C:D0:F8","68:5B:36","70:3E:AC","78:4F:43","88:53:2C","90:84:0D","94:DB:49","98:01:A7","B8:E8:56","C8:4C:75","D8:9A:34","F0:18:98","F0:9A:51","F4:0F:24","FC:E9:98")
                        $androidOuics = @("00:12:FB","00:15:99","50:01:D9","B0:5C:DA","EC:1F:72","70:85:C2","00:1A:11","3C:5A:B4","DA:A1:19","A4:77:33","00:0F:90","18:2B:0A","48:FD:8E","54:9F:13","00:18:82","3C:5C:1C","54:07:CC","DA:AE:C7","00:1E:66","A8:B8:E0","44:65:0D")
                        if ($appleOuics -contains $oui) { $scores.Apple += 1 }
                        elseif ($androidOuics -contains $oui) { $scores.Linux += 1 }
                    }
                }
            } catch {}

            # Determine OS
            $sortedScores = $scores.GetEnumerator() | Sort-Object Value -Descending
            $top = $sortedScores[0]
            $totalScore = ($scores.Values | Measure-Object -Sum).Sum

            $osLabels = @{ Windows = "Windows"; Linux = "Linux / Android"; Apple = "Apple (macOS/iOS)"; Network = "Network / IoT Device" }
            $os = if ($top.Value -eq 0) { "Unknown" } else { $osLabels[$top.Name] }
            $pct = if ($totalScore -gt 0) { [math]::Round(($top.Value / $totalScore) * 100) } else { 0 }
            $confidence = if ($pct -ge 80) { "very high" } elseif ($pct -ge 60) { "high" } elseif ($pct -ge 40) { "medium" } else { "low" }

            # Format open port hints for display
            $portHint = ""
            $serviceLabels = @{ 22 = "SSH"; 23 = "Telnet"; 80 = "HTTP"; 139 = "NetBIOS"; 443 = "HTTPS"; 445 = "SMB"; 3389 = "RDP"; 5000 = "AirPlay"; 5555 = "ADB"; 62078 = "iTunes" }
            if ($openPorts.Count -gt 0) {
                $labels = $openPorts | ForEach-Object { if ($serviceLabels.ContainsKey($_)) { $serviceLabels[$_] } else { "$_" } }
                $portHint = " [" + ($labels -join ", ") + "]"
            }

            return [PSCustomObject]@{
                IP           = $IP
                Hostname     = if ($hostName) { $hostName } else { "Unavailable" }
                OS           = $os
                Confidence   = $confidence
                PortSignals  = $portHint
                TTL          = $ttl
                Score        = $top.Value
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

            $hostResults = [System.Collections.Generic.List[object]]::new()
            $pending = $HostRunspaces.Count
            $timeout = (Get-Date).AddSeconds(60)
            while ($pending -gt 0 -and (Get-Date) -lt $timeout) {
                for ($i = 0; $i -lt $HostRunspaces.Count; $i++) {
                    $r = $HostRunspaces[$i]
                    if ($r -and $r.Async.IsCompleted) {
                        $HostRunspaces[$i] = $null; $pending--
                        $res = $r.Pipe.EndInvoke($r.Async)
                        $r.Pipe.Dispose()
                        if ($res) { $hostResults.Add($res) }
                    }
                }
                if ($pending -gt 0) { Start-Sleep -Milliseconds 100 }
            }
            foreach ($r in $HostRunspaces) {
                if ($r) { $r.Pipe.Dispose() }
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
                $color = switch ($res.Confidence) {
                    "very high" { "Green" }
                    "high"      { "Green" }
                    "medium"    { "Yellow" }
                    default     { "DarkGray" }
                }
                Write-Host "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS) (confidence: $($res.Confidence))$($res.PortSignals)" -ForegroundColor $color
                $scanLog += "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS) (confidence: $($res.Confidence), TTL: $($res.TTL))$($res.PortSignals)"
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
        [Parameter(Mandatory = $false)]
        [string[]]$OutputData,

        [Parameter(Mandatory = $false)]
        [switch]$SuppressSave
    )

    do {
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

                Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
                $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
                $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
                $saveDialog.FileName = $defaultFile
                $saveDialog.Title = "Select Destination for Scan Results"

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
        }
        else {
            $action = "menu"
        }
    } while ($action -ne "menu")

    Start-NeoRadar
}

Start-NeoRadar

    Write-Host "        ░▒▓█ NEO RADAR v1.12 █▓▒░          " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor DarkMagenta
    Write-Host "             Created By ItsNEOx             " -ForegroundColor Magenta
    Write-Host "      The super simple network scanner      " -ForegroundColor DarkCyan
    Write-Host "            for legal purposes              " -ForegroundColor DarkGray
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
    Write-Host ""

    $DefaultPrefix = "192.168.0"
    $CurrentVersion = "1.12"
    $RepoRawUrl = "https://raw.githubusercontent.com/ItsNEOx/NEO-Radar-Powershell-7/main/neoradar.ps1"
    $RepoWebUrl = "https://github.com/ItsNEOx/NEO-Radar-Powershell-7"

    # --- Non-Windows detection (this script is Windows-only) ---
    if ($PSVersionTable.PSEdition -eq "Core" -and ($IsLinux -or $IsMacOS)) {
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host " [!] NOT A WINDOWS SYSTEM" -ForegroundColor Yellow
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host " This is a Windows PowerShell script." -ForegroundColor Gray
        Write-Host " It will NOT work on Linux, macOS, or Termux." -ForegroundColor Yellow
        Write-Host " Use the bash version (neoradar) instead." -ForegroundColor Gray
        Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta
        Write-Host ""
    }

    Write-Host "Choose scan mode:" -ForegroundColor Cyan
    Write-Host "1) Network Ping Scan"
    Write-Host "2) Single Host Inspection (Ports + Hostname + OS)"
    Write-Host "3) Ping + TCP port scan"
    Write-Host "4) ARP Device MAC Lookup & Vendor Identification"
    Write-Host "5) Hostname Scan & Fingerprinting"
    Write-Host "6) Help / Feature Guide"
    Write-Host "7) Check for Updates"
    Write-Host "8) Nmap Command Reference"
    Write-Host "E) Exit Program"
    Write-Host ""

    do {
        $Mode = Read-Host "Enter option number or 'E' to Exit (default: 1)"

        if ($Mode -eq 'e' -or $Mode -eq 'E') {
            Write-Host "`nGoodbye." -ForegroundColor Cyan
            exit
        }

        if ([string]::IsNullOrWhiteSpace($Mode)) { $Mode = "1"; break }

        $valid = $Mode -match '^[1-8]$'
        if (-not $valid) {
            Write-Host "  [!] Please enter a number between 1 and 8, or 'E' to exit." -ForegroundColor Yellow
        }
    } while (-not $valid)

    $Mode = [int]$Mode

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
        Write-Host "   handshakes against common service ports." -ForegroundColor Gray
        Write-Host "   All ports scanned per host in a single runspace (batched for speed)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "4) ARP Device MAC Lookup & Vendor Identification" -ForegroundColor Yellow
        Write-Host "   Queries local network ARP tables to map discovered IP addresses" -ForegroundColor Gray
        Write-Host "   to physical Hardware MAC addresses and identifies the device vendor." -ForegroundColor Gray
        Write-Host "   Uses a single broadcast ping to refresh the ARP table (much faster)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "5) Hostname Scan & Fingerprinting" -ForegroundColor Yellow
        Write-Host "   Resolves reverse DNS entries and LLMNR names for subnet devices," -ForegroundColor Gray
        Write-Host "   estimating OS family (Windows, Linux, Cisco) based on ICMP TTL values." -ForegroundColor Gray
        Write-Host ""

        Write-Host "7) Check for Updates" -ForegroundColor Yellow
        Write-Host "   Checks GitHub for new releases and redirects to the web page to download." -ForegroundColor Gray
        Write-Host ""

        Write-Host "8) Nmap Command Reference" -ForegroundColor Yellow
        Write-Host "   Shows the equivalent Nmap commands for each Neo-Radar scan mode," -ForegroundColor Gray
        Write-Host "   with explanations of flags and how each technique works." -ForegroundColor Gray
        Write-Host ""

        Write-Host "Android/Termux Note:" -ForegroundColor Red
        Write-Host "   This is a Windows PowerShell script and will NOT" -ForegroundColor Gray
        Write-Host "   run on Termux or Android terminals." -ForegroundColor Yellow
        Write-Host "   A bash version is included (neoradar) that works" -ForegroundColor Gray
        Write-Host "   on Linux desktop and Termux." -ForegroundColor Gray
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
    # Mode 8 — Nmap Command Reference
    # -------------------------------------------------------------
    if ($Mode -eq 8) {
        Clear-Host
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "       NEO RADAR - Nmap Command Guide       " -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "   How to perform each scan mode with Nmap " -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host ""

        Write-Host "1) Network Ping Scan" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: ICMP sweep across a range of IPs." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sn 192.168.0.0/24" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sn  -> Ping sweep only (no port scan)" -ForegroundColor DarkGray
        Write-Host "     /24  -> CIDR notation for 192.168.0.1-254" -ForegroundColor DarkGray
        Write-Host "   How it works: Sends ICMP echo requests, TCP SYN to port 443," -ForegroundColor Gray
        Write-Host "   TCP ACK to port 80, and ICMP timestamp requests simultaneously." -ForegroundColor Gray
        Write-Host "   Hosts responding to any of these are marked alive." -ForegroundColor Gray
        Write-Host ""

        Write-Host "2) Single Host Inspection" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Ping + TTL OS guess + DNS + port scan on one IP." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -A 192.168.0.1" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -A  -> Aggressive scan (OS detection -O," -ForegroundColor DarkGray
        Write-Host "            version detection -sV, script scanning -sC," -ForegroundColor DarkGray
        Write-Host "            and traceroute --traceroute)" -ForegroundColor DarkGray
        Write-Host "   How it works: Combines multiple Nmap subsystems into" -ForegroundColor Gray
        Write-Host "   one comprehensive scan against a single target." -ForegroundColor Gray
        Write-Host "   Use -p- to scan all 65535 ports (takes much longer)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "3) Ping + TCP Port Scan" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Discover live hosts, then scan common TCP ports." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sS 192.168.0.0/24 -p 21,22,23,25,53,80,110," -ForegroundColor Green
        Write-Host "                     135,139,143,443,445,993,995,1433," -ForegroundColor Green
        Write-Host "                     3306,3389,5900,8080,8443" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sS -> SYN scan (half-open, faster, requires admin/root)" -ForegroundColor DarkGray
        Write-Host "     -sT -> TCP connect scan (no root needed, slower)" -ForegroundColor DarkGray
        Write-Host "     -p  -> Port range or comma-separated list" -ForegroundColor DarkGray
        Write-Host "   How it works: Sends SYN packet; if SYN/ACK comes back," -ForegroundColor Gray
        Write-Host "   port is open. RST indicates closed. No response = filtered." -ForegroundColor Gray
        Write-Host "   On Windows without admin, use -sT instead of -sS." -ForegroundColor Gray
        Write-Host ""

        Write-Host "4) ARP MAC Lookup & Vendor Identification" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: Queries local ARP table for MAC addresses." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -PR 192.168.0.0/24" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -PR -> ARP ping (local subnet only, fastest method)" -ForegroundColor DarkGray
        Write-Host "   How it works: Nmap sends ARP requests and reads replies." -ForegroundColor Gray
        Write-Host "   ARP is Layer-2, so it only works on the local subnet." -ForegroundColor Gray
        Write-Host "   It is the fastest and most reliable host discovery method" -ForegroundColor Gray
        Write-Host "   for local networks. To see MACs with a standard scan," -ForegroundColor Gray
        Write-Host "   use: nmap -sn 192.168.0.0/24" -ForegroundColor Gray
        Write-Host "   (MACs appear in the output on the same subnet)." -ForegroundColor Gray
        Write-Host ""

        Write-Host "5) Hostname Scan & Fingerprinting" -ForegroundColor Yellow
        Write-Host "   Neo-Radar: DNS/LLMNR hostname resolution + TTL OS estimate." -ForegroundColor Gray
        Write-Host "   Nmap:      nmap -sL 192.168.0.0/24    (list scan / DNS lookup)" -ForegroundColor Green
        Write-Host "             nmap -O 192.168.0.0/24     (OS detection)" -ForegroundColor Green
        Write-Host "   Flags:" -ForegroundColor DarkCyan
        Write-Host "     -sL -> List scan — reverse-DNS resolves all IPs" -ForegroundColor DarkGray
        Write-Host "     -O  -> OS detection (TCP/IP stack fingerprinting)" -ForegroundColor DarkGray
        Write-Host "     --osscan-guess -> Guesses OS more aggressively" -ForegroundColor DarkGray
        Write-Host "   How it works: -sL queries DNS for each IP in range." -ForegroundColor Gray
        Write-Host "   -O analyzes subtle differences in TCP packet responses" -ForegroundColor Gray
        Write-Host "   (initial TTL, window size, DF flag, TCP options order)" -ForegroundColor Gray
        Write-Host "   to fingerprint the operating system with high accuracy." -ForegroundColor Gray
        Write-Host ""

        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host " Quick Reference" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor DarkMagenta
        Write-Host "  -sn       Ping sweep host discovery" -ForegroundColor Green
        Write-Host "  -sS       SYN half-open scan (requires admin)" -ForegroundColor Green
        Write-Host "  -sT       TCP connect scan" -ForegroundColor Green
        Write-Host "  -sV       Service/version detection" -ForegroundColor Green
        Write-Host "  -O        OS fingerprinting" -ForegroundColor Green
        Write-Host "  -sC       Default NSE script scan" -ForegroundColor Green
        Write-Host "  -A        Aggressive (-O -sV -sC --traceroute)" -ForegroundColor Green
        Write-Host "  -PR       ARP ping (local subnet)" -ForegroundColor Green
        Write-Host "  -sL       List scan / DNS resolution" -ForegroundColor Green
        Write-Host "  -p <n>    Port range (e.g. -p 1-1000 or -p- for all)" -ForegroundColor Green
        Write-Host "  -T<0-5>   Timing template (T4 is faster, T5 is insane)" -ForegroundColor Green
        Write-Host "  -v        Increase verbosity" -ForegroundColor Green
        Write-Host "  --reason  Shows why Nmap concluded a port state" -ForegroundColor Green
        Write-Host ""

        Show-EndOptions -SuppressSave
        return
    }

    # -------------------------------------------------------------
    # Mode 2 — Single Host Inspection
    # -------------------------------------------------------------
    if ($Mode -eq 2) {
        Write-Host "Enter 'B' for Main Menu, or 'E' to Exit." -ForegroundColor DarkGray
        do {
            $TargetIP = Read-Host "Enter target IP address (Example : 192.168.0.1)"

            if ($TargetIP -eq 'e' -or $TargetIP -eq 'E') {
                Write-Host "`nGoodbye." -ForegroundColor Cyan
                exit
            }

            if ([string]::IsNullOrWhiteSpace($TargetIP) -or $TargetIP -eq 'b' -or $TargetIP -eq 'B') {
                Start-NeoRadar
                return
            }

            if ($TargetIP -notmatch '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') {
                Write-Host "  [!] Invalid IP format. Use the form 192.168.0.1" -ForegroundColor Yellow
                continue
            }

            $valid = $true
            $octets = $TargetIP -split '\.'
            foreach ($octet in $octets) {
                if ([int]$octet -lt 0 -or [int]$octet -gt 255) {
                    Write-Host "  [!] Each octet must be between 0 and 255." -ForegroundColor Yellow
                    $valid = $false
                    break
                }
            }
        } while (-not $valid)

        Write-Host "`n[+] Inspecting single host: $TargetIP..." -ForegroundColor Cyan

        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($TargetIP, 400)
        $ping.Dispose()

        if ($reply.Status -ne "Success") {
            Write-Host "  [-] Host $TargetIP did not respond to ping." -ForegroundColor Yellow
            Show-EndOptions
            return
        }

        Write-Host "  [+] Host Status: ONLINE" -ForegroundColor Green

        $ttl = $reply.Options.Ttl
        $os = "Unknown"
        if ($ttl -ge 100 -and $ttl -le 128) { $os = "Windows" }
        elseif ($ttl -ge 32 -and $ttl -le 64) { $os = "Linux / macOS / Mobile" }
        elseif ($ttl -ge 240) { $os = "Cisco / Network Device" }

        $hostName = $null
        try { $hostName = [System.Net.Dns]::GetHostEntry($TargetIP).HostName } catch {}

        if (-not $hostName) {
            try {
                $llmnr = Resolve-DnsName -LlmnrOnly -Name $TargetIP -ErrorAction SilentlyContinue
                if ($llmnr) { $hostName = $llmnr.NameHost }
            } catch {}
        }
        if (-not $hostName) { $hostName = "Unavailable" }

        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5900, 8080, 8443)
        $openPorts = @()

        foreach ($port in $Ports) {
            $tcp = New-Object System.Net.Sockets.TcpClient
            try {
                $async = $tcp.BeginConnect($TargetIP, $port, $null, $null)
                if ($async.AsyncWaitHandle.WaitOne(100, $false) -and $tcp.Connected) {
                    $tcp.EndConnect($async)
                    $openPorts += $port
                }
            } catch {} finally { $tcp.Close(); $tcp.Dispose() }
        }

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

    do {
        $StartInput = Read-Host "Enter starting host number (1-255, default: 1)"
        if ($StartInput -eq 'e' -or $StartInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
        if ($StartInput -eq 'b' -or $StartInput -eq 'B') { Start-NeoRadar; return }
        if ([string]::IsNullOrWhiteSpace($StartInput)) { $Start = 1; break }
        if ($StartInput -notmatch '^(?:[1-9]|[12]\d|25[0-5])$') {
            Write-Host "  [!] Numbers only, between 1 and 255." -ForegroundColor Yellow
            $valid = $false
        } else {
            $Start = [int]$StartInput; break
        }
    } while ($true)

    do {
        $EndInput = Read-Host "Enter ending host number (1-255, default: 254)"
        if ($EndInput -eq 'e' -or $EndInput -eq 'E') { Write-Host "`nGoodbye." -ForegroundColor Cyan; exit }
        if ($EndInput -eq 'b' -or $EndInput -eq 'B') { Start-NeoRadar; return }
        if ([string]::IsNullOrWhiteSpace($EndInput)) { $End = 254; break }
        if ($EndInput -notmatch '^(?:[1-9]|[12]\d|25[0-5])$') {
            Write-Host "  [!] Numbers only, between 1 and 255." -ForegroundColor Yellow
        } else {
            $End = [int]$EndInput; break
        }
    } while ($true)

    if ($Start -gt $End) {
        Write-Host "  [!] Starting host cannot be greater than ending host." -ForegroundColor Yellow
        Start-NeoRadar
        return
    }

    Write-Host "`n[+] Starting live sweep on $Prefix.$Start through $Prefix.$End..." -ForegroundColor Cyan
    Write-Host "--------------------------------------------" -ForegroundColor DarkMagenta

    # --- Optimized Ping Engine (WaitHandle-based completion, no busy-poll) ---
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
            }
        }

        # Stream completions using IsCompleted (no Where-Object overhead per iteration)
        $rawDiscovered = [System.Collections.Generic.List[string]]::new()
        $pending = $Runspaces.Count

        while ($pending -gt 0) {
            for ($i = 0; $i -lt $Runspaces.Count; $i++) {
                $r = $Runspaces[$i]
                if ($r -and $r.Async.IsCompleted) {
                    $Runspaces[$i] = $null
                    $pending--
                    $result = $r.Pipe.EndInvoke($r.Async)
                    $r.Pipe.Dispose()
                    if ($result) {
                        $rawDiscovered.Add($result.IP)
                        Write-Host "  [+] Discovered: $($result.IP) [RTT: $($result.RTT)ms]" -ForegroundColor Green
                    }
                }
            }
            if ($pending -gt 0) { Start-Sleep -Milliseconds 50 }
        }
    } finally {
        $Pool.Close(); $Pool.Dispose()
    }

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
    # Mode 3 — Ping + TCP port scan (BATCHED: all ports per runspace)
    # -------------------------------------------------------------
    if ($Mode -eq 3) {
        Write-Host "`n[+] Scanning common service ports..." -ForegroundColor Cyan

        $Ports = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3306, 3389, 5900, 8080, 8443)
        $Pool = [runspacefactory]::CreateRunspacePool(1, 64)
        $Pool.Open()

        $PortScript = {
            param($TargetHost, $Ports)
            $open = @()
            foreach ($port in $Ports) {
                $tcp = New-Object System.Net.Sockets.TcpClient
                try {
                    $async = $tcp.BeginConnect($TargetHost, $port, $null, $null)
                    if ($async.AsyncWaitHandle.WaitOne(100, $false) -and $tcp.Connected) {
                        $tcp.EndConnect($async)
                        $open += $port
                    }
                } catch {} finally { $tcp.Close(); $tcp.Dispose() }
            }
            return [PSCustomObject]@{ Host = $TargetHost; OpenPorts = $open }
        }

        try {
            $TcpRunspaces = @()
            foreach ($target in $alive) {
                $Powershell = [powershell]::Create().AddScript($PortScript).AddArgument($target).AddArgument($Ports)
                $Powershell.RunspacePool = $Pool
                $TcpRunspaces += [PSCustomObject]@{
                    Pipe  = $Powershell
                    Async = $Powershell.BeginInvoke()
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

        $grouped = $results | Group-Object Host | Sort-Object { [int]($_.Name -split '\.')[3] }

        $scanLog = @(
            "============================================",
            " NEO RADAR - Ping + TCP Port Scan Log",
            " Timestamp : $(Get-Date)",
            " Target    : $Prefix.$Start-$End",
            "--------------------------------------------"
        )

        foreach ($g in $grouped) {
            $allPorts = $g.Group[0].OpenPorts
            if ($allPorts -and $allPorts.Count -gt 0) {
                Write-Host "`nHost: $($g.Name)" -ForegroundColor Yellow
                Write-Host "-------------------------" -ForegroundColor DarkMagenta
                $scanLog += "`nHost: $($g.Name)"
                foreach ($p in $allPorts) {
                    Write-Host "  Port $p : OPEN" -ForegroundColor Green
                    $scanLog += "  Port $p : OPEN"
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
    # Mode 4 — Fast ARP Device Identification (single broadcast ping)
    # -------------------------------------------------------------
    if ($Mode -eq 4) {
        Write-Host "`n[+] Refreshing local ARP table with broadcast ping..." -ForegroundColor Cyan

        $broadcast = "$Prefix.255"
        $ping = New-Object System.Net.NetworkInformation.Ping
        $ping.Send($broadcast, 200) | Out-Null
        $ping.Dispose()
        Start-Sleep -Milliseconds 300

        $arpOutput = arp -a
        $arpEntries = foreach ($line in $arpOutput) {
            if ($line -match "dynamic") {
                $parts = $line -split "\s+" | Where-Object { $_ }
                if ($parts.Count -ge 2) {
                    [PSCustomObject]@{ IP = $parts[0]; MAC = $parts[1].ToUpper() }
                }
            }
        }

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

                if ($OuiTable.ContainsKey($oui)) {
                    $vendor = $OuiTable[$oui]
                } else {
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

            # --- Multi-method hostname resolution ---
            $hostName = $null
            try { $hostName = [System.Net.Dns]::GetHostEntry($IP).HostName } catch {}

            if (-not $hostName) {
                try {
                    $ptr = Resolve-DnsName -Name $IP -Type PTR -ErrorAction SilentlyContinue
                    if ($ptr) { $hostName = $ptr.NameHost }
                } catch {}
            }

            if (-not $hostName) {
                try {
                    $llmnr = Resolve-DnsName -LlmnrOnly -Name $IP -ErrorAction SilentlyContinue
                    if ($llmnr) { $hostName = $llmnr.NameHost }
                } catch {}
            }

            # --- NetBIOS name (Windows hosts) ---
            $netbiosName = $null
            try {
                $nbt = nbtstat -A $IP 2>$null
                if ($nbt) {
                    $lines = $nbt | Select-String "<00>" | Where-Object { $_ -notmatch "<GROUP>" }
                    if ($lines) {
                        $netbiosName = ($lines[0] -split '\s+')[0]
                        if (-not $hostName) { $hostName = $netbiosName }
                    }
                }
            } catch {}

            # --- ICMP ping + TTL ---
            $ttl = 0
            $ping = New-Object System.Net.NetworkInformation.Ping
            try {
                $reply = $ping.Send($IP, 200)
                if ($reply.Status -eq "Success") { $ttl = $reply.Options.Ttl }
            } catch {} finally { $ping.Dispose() }

            # --- Key port probing (fast asynchronous) ---
            $keyPorts = @(22, 23, 80, 139, 443, 445, 3389)
            $openPorts = @()
            foreach ($port in $keyPorts) {
                $tcp = New-Object System.Net.Sockets.TcpClient
                try {
                    $async = $tcp.BeginConnect($IP, $port, $null, $null)
                    if ($async.AsyncWaitHandle.WaitOne(40, $false) -and $tcp.Connected) {
                        $tcp.EndConnect($async)
                        $openPorts += $port
                    }
                } catch {} finally { $tcp.Close(); $tcp.Dispose() }
            }

            # --- HTTP banner grab on port 80 ---
            $serverHeader = $null
            if ($openPorts -contains 80) {
                try {
                    $socket = New-Object System.Net.Sockets.TcpClient
                    $async = $socket.BeginConnect($IP, 80, $null, $null)
                    if ($async.AsyncWaitHandle.WaitOne(100, $false) -and $socket.Connected) {
                        $socket.EndConnect($async)
                        $stream = $socket.GetStream()
                        $writer = New-Object System.IO.StreamWriter($stream)
                        $writer.Write("HEAD / HTTP/1.0`r`n`r`n")
                        $writer.Flush()
                        $reader = New-Object System.IO.StreamReader($stream)
                        $response = $reader.ReadToEnd()
                        foreach ($line in ($response -split "`r`n")) {
                            if ($line -match "^Server:\s*(.+)$") {
                                $serverHeader = $matches[1].Trim()
                                break
                            }
                        }
                        $reader.Dispose()
                        $writer.Dispose()
                        $stream.Dispose()
                    }
                } catch {} finally { $socket.Close() }
            }

            # --- Combined multi-signal OS scoring ---
            $scores = @{ Windows = 0; Linux = 0; Network = 0 }

            # TTL evidence
            if ($ttl -ge 100 -and $ttl -le 128) { $scores.Windows += 2 }
            elseif ($ttl -ge 32 -and $ttl -le 64) { $scores.Linux += 2 }
            elseif ($ttl -ge 240 -and $ttl -le 255) { $scores.Network += 2 }

            # Port evidence
            if ($openPorts -contains 445) { $scores.Windows += 3 }
            if ($openPorts -contains 139) { $scores.Windows += 2 }
            if ($openPorts -contains 3389) { $scores.Windows += 2 }
            if ($openPorts -contains 22) { $scores.Linux += 2 }
            if ($openPorts -contains 23) { $scores.Network += 2 }

            # HTTP server header
            if ($serverHeader) {
                if ($serverHeader -match "Microsoft-IIS") { $scores.Windows += 2 }
                elseif ($serverHeader -match "Apache") { $scores.Linux += 1 }
                elseif ($serverHeader -match "nginx") { $scores.Linux += 1 }
            }

            # NetBIOS name is strongly Windows
            if ($netbiosName) { $scores.Windows += 3 }

            # Determine OS and confidence
            $sortedScores = $scores.GetEnumerator() | Sort-Object Value -Descending
            $top = $sortedScores[0]
            $second = $sortedScores[1]
            $totalScore = ($scores.Values | Measure-Object -Sum).Sum

            $os = if ($top.Value -eq 0) { "Unknown" } else { $top.Name }

            $pct = if ($totalScore -gt 0) { [math]::Round(($top.Value / $totalScore) * 100) } else { 0 }
            $confidence = if ($pct -ge 80) { "very high" } elseif ($pct -ge 60) { "high" } elseif ($pct -ge 40) { "medium" } else { "low" }

            # Format open port hints for display
            $portHint = ""
            $serviceLabels = @{ 22 = "SSH"; 23 = "Telnet"; 80 = "HTTP"; 139 = "NetBIOS"; 443 = "HTTPS"; 445 = "SMB"; 3389 = "RDP" }
            if ($openPorts.Count -gt 0) {
                $labels = $openPorts | ForEach-Object { if ($serviceLabels.ContainsKey($_)) { $serviceLabels[$_] } else { "$_" } }
                $portHint = " [" + ($labels -join ", ") + "]"
            }

            return [PSCustomObject]@{
                IP           = $IP
                Hostname     = if ($hostName) { $hostName } else { "Unavailable" }
                OS           = $os
                Confidence   = $confidence
                PortSignals  = $portHint
                TTL          = $ttl
                Score        = $top.Value
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
                $color = switch ($res.Confidence) {
                    "very high" { "Green" }
                    "high"      { "Green" }
                    "medium"    { "Yellow" }
                    default     { "DarkGray" }
                }
                Write-Host "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS) (confidence: $($res.Confidence))$($res.PortSignals)" -ForegroundColor $color
                $scanLog += "  $($res.IP) -> Host: $($res.Hostname) | OS: $($res.OS) (confidence: $($res.Confidence), TTL: $($res.TTL))$($res.PortSignals)"
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
        [Parameter(Mandatory = $false)]
        [string[]]$OutputData,

        [Parameter(Mandatory = $false)]
        [switch]$SuppressSave
    )

    do {
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

                Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
                $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
                $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
                $saveDialog.FileName = $defaultFile
                $saveDialog.Title = "Select Destination for Scan Results"

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
        }
        else {
            $action = "menu"
        }
    } while ($action -ne "menu")

    Start-NeoRadar
}

Start-NeoRadar
