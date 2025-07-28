How to Install No-IP Linux DUC 3
   2   │ ================================
   3   │
   4   │ With a Package
   5   │ --------------
   6   │
   7   │ Download the package and install as your OS recommends. For instance, with Ubuntu,
   8   │
   9   │ ```
  10   │ dpkg -i noip-duc_3*.deb
  11   │ ```
  12   │
  13   │ Then create the config. See Configuration section below.
  14   │
  15   │ Statically-linked Binary
  16   │ ----------------------
  17   │
  18   │ No-IP provides a statically-linked binary of `noip-duc`. It should run on any Linux as long as the architecture is correct. For instance, if y
       │ ou use a current Intel or AMD processor, choose the package with the architecture `x86_64`.
  19   │
  20   │ ```
  21   │ tar xzvf noip-duc_3*-musl.gz
  22   │ sudo mv noip-duc_3*-musl /usr/local/bin/noip-duc
  23   │ ```
  24   │
  25   │ Create an init script to run `noip-duc` on startup. Here is a simple Systemd service unit,
  26   │
  27   │ ```
  28   │ [Unit]
  29   │ Description=No-IP Dynamic Update Client
  30   │ After=network.target auditd.service

  [Service]
  33   │ EnvironmentFile=/etc/default/noip-duc
  34   │ ExecStart=/usr/local/bin/noip-duc
  35   │ Restart=on-failure
  36   │ Type=simple
  37   │
  38   │ [Install]
  39   │ WantedBy=multi-user.target
  40   │ ```
  41   │
  42   │ From Source
  43   │ -----------
  44   │
  45   │ [Rust](https://www.rust-lang.org/) is required to build from source. Follow the instructions at https://rustup.rs/
  46   │
  47   │ ```
  48   │ curl -OL https://www.noip.com/download/linux\?package=source > noip-duc3.tgz
  49   │ tar xzvf noip-duc3.tgz
  50   │ cd noip-duc-*
  51   │ cargo build --release
  52   │ sudo cp target/release/noip-duc /usr/local/bin
  53   │
  54   │ # For systemd.
  55   │ # - On non-Debian OSes, edit the EnvironmentFile entry.
  56   │ sed '/^ExecStart=/ s#usr/bin#usr/local/bin#' debian/service | sudo tee /etc/systemd/system/noip-duc.service
  57   │ sudo systemctl daemon-reload
  58   │ ```

  Configuration
  61   │ =============
  62   │
  63   │ Configuration may be done with command line options or environment variables. Environment variables make it easy to create a configuration fil
       │ e that integrates with Systemd, sysvinit, or other init system.
  64   │
  65   │ Here is an example configuration file. It contains a password, so set permissions appropriately, ideally `0600`. See `noip-duc --help` for a f
       │ ull explanation of each option.
  66   │
  67   │ ```
  68   │ ## /etc/defaults/noip-duc (Debian) or /etc/sysconfig/noip-duc (RedHat, Suse)
  69   │ ## or anywhere you like.
  70   │ NOIP_USERNAME=
  71   │ NOIP_PASSWORD=
  72   │
  73   │ ## Comma separated list of hostnames and group names
  74   │ NOIP_HOSTNAMES=
  75   │
  76   │ ## Less common options
  77   │ #NOIP_CHECK_INTERVAL=5m
  78   │ #NOIP_EXEC_ON_CHANGE=
  79   │ #NOIP_HTTP_TIMEOUT=10s
  80   │ ## ip methods: aws, http, http-port-8245, static:<IP>
  81   │ #NOIP_IP_METHOD=dns,http,http-port-8245
  82   │ #NOIP_LOG_LEVEL=info
  83   │
  84   │ ## Daemon options should not be set if using systemd. They only apply when `--daemon` is used.
  85   │ #NOIP_DAEMON_GROUP=
  86   │ #NOIP_DAEMON_PID_FILE=
  87   │ #NOIP_DAEMON_USER=
  88   │ ```

  89   │
  90   │ Migrating From noip2
  91   │ --------------------
  92   │
  93   │ `noip-duc` includes a method to generate an environment variables file from the noip2 config.
  94   │
  95   │ ```
  96   │ noip-duc --import /usr/local/etc/no-ip2.conf | sudo tee /etc/default/noip-duc