# ░▒▓█ NEO RADAR v1.12 █▓▒░

function Start-NeoRadar {

    Clear-Host
    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkMagenta
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
