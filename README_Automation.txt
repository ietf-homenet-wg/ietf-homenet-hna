This file is a scratchpad to document the process of creating, delegating, and managing the Homenet zone.

1st step is to document and understand the manual process, and what input and code is required at each step.
2nd pass is to identify alternatives.
3rd pass is to prototype automation.
4th pass is to productionise automation.

Once we have this we can work backwards to see what is essential for the architecture and what is implementation dependent.


1. Creating the Service Relationship

1.1. Identifying an Outsource Service Provider

Manual task:  search for potential outsource service providers

Input:  parent domain names e.g. homenetdns.com homenetinfra.com
Output: config file of chosen parent domain name.

Potential Automation: pre-configure alternative providers in config file. Add GUI to select provider or manual override.

1.2. Registering as a Customer

Manual task: Out of band via web site
Input:  money or other token
Output: name of the homenet zone to be delegated e.g. hn1.homenetinfra.com
Output: username?

Alternative: build on an existing trust relationship between an IoT manufacturer and a DNS Outsourcing Provider
Input:  baked in certificate or keying material on the IoT device installed at time of manufacture


1.3. Initial Configuration of Service Provider Resources

1.4. Initial Configuration of Homenet Resources

2. Creating the Initial Homenet Zone

2.1. Creating or Learning a Blank Template Zone

Manual Task: Create blank zone

Alternative: dig SOA from parent zone of the homenet zone to learn NS records etc.
  Disadvantage: tied to the same list of NS as parent zone.
  Advantage:    simple and standard
  Code:         dig -t soa dnsinfra.com
  
Alternative: AXFR blank zone from template server to learn NS records etc.
  Disadvantage: requires some for of ident or keying material to prevent abuse of the template server? Or at least rate limiting
  Disadvantage: have to discover the template server
  Advantage:    different users can be distributed over many NS. Template zone file can be created on the fly
  Code:         dig @template_server -t axfr <delegated zone>.dnsinfra.com
  
  
Output: Blank zone file

more fwd.hn1.homenetinfra.com.db
$TTL 600; TTL default
$ORIGIN <delegated zone>.homenetinfra.com.

@       IN      SOA ns1.homenetinfra.com. hostmaster.globis.net. (
                2019052901 ;Serial
                3600 ;Refresh
                1800 ;Retry
                604800 ;Expire
                600 ;NX Minimum TTL
                )

        IN      NS ns1.homenetinfra.com.
        IN      NS ns2.homenetinfra.com.


2.2. Creating Keys for the Homenet Zone

Manual task: run dnssec-keygen

Input: name of the homenet zone to be delegated e.g. hn1.homenetinfra.com
Code: bind dnssec-keygen. Not in dnsmasq?
Output: public and private KSK and ZSK files.


dnssec-keygen -f KSK -3 -a ECDSAP256SHA256  -b 256  -n ZONE <delegated zone>.homenetinfra.com
Generating key pair.
K<delegated zone>.homenetinfra.com.+013+02708
dnssec-keygen  -3 -a ECDSAP256SHA256  -b 256  -n ZONE <delegated zone>.homenetinfra.com
Generating key pair.
K<delegated zone>.homenetinfra.com.+013+22675

Automation: trivial if there's code for generating keys


2.3. Populating the Initial Homenet Zone

Manual task: edit the blank zone file and append A and AAAA records
Code: Text editing

Automation: learn hostnames from DHCP (dnsmasq)


2.4. Signing the Initial Homenet Zone

Input:  unsigned initial Homenet Zone
Code:   bind dnssec-signzone. Not in dnsmasq?
Output: Signed zone
Output: DS Set

dnssec-signzone -S -K . -g -a  -o hn1.homenetinfra.com fwd.hn1.homenetinfra.com.db
Fetching hn1.homenetinfra.com/ECDSAP256SHA256/22675 (ZSK) from key repository.
Fetching hn1.homenetinfra.com/ECDSAP256SHA256/2708 (KSK) from key repository.
Verifying the zone using the following algorithms: ECDSAP256SHA256.
Zone fully signed:
Algorithm: ECDSAP256SHA256: KSKs: 1 active, 0 stand-by, 0 revoked
                            ZSKs: 1 active, 0 stand-by, 0 revoked
fwd.hn1.homenetinfra.com.db.signed

dsset-hn1.homenetinfra.com.           Khn1.homenetinfra.com.+013+02708.private
fwd.hn1.homenetinfra.com.db           Khn1.homenetinfra.com.+013+22675.key
fwd.hn1.homenetinfra.com.db.signed    Khn1.homenetinfra.com.+013+22675.private
Khn1.homenetinfra.com.+013+02708.key

more *.signed
; File written on Mon Jun  3 09:14:52 2019
; dnssec_signzone version 9.14.2

hn1.homenetinfra.com.   600     IN SOA  ns1.homenetinfra.com. hostmaster.globis.net. (
                                        2019052901 ; serial
                                        3600       ; refresh (1 hour)
                                        1800       ; retry (30 minutes)
                                        604800     ; expire (1 week)
                                        600        ; minimum (10 minutes)
                                        )
                        600     RRSIG   SOA 13 3 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        GFhfMH2F7aGnY9CMtaQTFWsFgQdKuGaLbvC/
                                        jPuk0wUzdRVUNj+HuZFtiGTD8LiXXQZ5qNBW
                                        R8RYuCYAqG4yQg== )
                        600     NS      ns1.homenetinfra.com.
                        600     NS      ns2.homenetinfra.com.
                        600     RRSIG   NS 13 3 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        4qJPIjKMOvz8D1FD1s5wM6wMJBYdelh/bCzz
                                        HTGzJ5y9FPAJY+UGbeL+TZleDnW7ydR0KVmZ
                                        r/9LHYLOrtb2vw== )
                        600     NSEC    www.hn1.homenetinfra.com. NS SOA RRSIG NSEC DNSKEY
                        600     RRSIG   NSEC 13 3 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        1Skcg7AUYPM1Iu8qivADJzqqLJNAhlzRrso0
                                        lDSQsUlzZ+76ovQxOBbe3V0M0Rv1ZnHmDhgr
                                        hQ7TdJ0qPtK2gQ== )
                        600     DNSKEY  256 3 13 (
                                        s16+52mwoQUvVRpCx4Gt5DvchZ68bqSqVp4u
                                        5o2g9nNk9cxnadTm1ULuSs6GBmF6L8tEXLKa
                                        8EKZjI1dMMWGZQ==
                                        ) ; ZSK; alg = ECDSAP256SHA256 ; key id= 22675
                        600     DNSKEY  257 3 13 (
                                        qVv6nHjL8Xsu9Wbp0HBWjW3z5iVPuJVNTVUX
                                        FZ792Nv3FeybVd5PNU7CbLnkthAaH11V+cKp
                                        vzygPQSQj9jBEA==
                                        ) ; KSK; alg = ECDSAP256SHA256 ; key id= 2708
                        600     RRSIG   DNSKEY 13 3 600 (
                                        20190703081452 20190603081452 2708 hn1.homenetinfra.com.
                                        ZIrGNa+1ALHr5JvK5f7+AGnUnAYfC1kXOX1U
                                        IbptRo3KMfe1TzufCuio2hAK98LE0TkkYnto
                                        wdwKK4FelKyxKA== )
                        600     RRSIG   DNSKEY 13 3 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        n6Hxi0CaKG4gNOridITHV/CwKpWlHUBNandb
                                        jsEK/yjxh1SmudIX04Nj26ZTxFKn6qfKEaM1
                                        QaxI3v7BAgeGYQ== )

www.hn1.homenetinfra.com. 600   IN A    92.111.140.210
                        600     RRSIG   A 13 4 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        WKpBcyJ9k9hRNthGZes5wrqMZ6FtUlIRdFHP
                                        Z+qeRBXpZSmRtxKQeW5AP199R2z13zCMq8MG
                                        lqABfik7A6Sb0w== )
                        600     NSEC    hn1.homenetinfra.com. A RRSIG NSEC
                        600     RRSIG   NSEC 13 4 600 (
                                        20190703081452 20190603081452 22675 hn1.homenetinfra.com.
                                        RACfSSIoe1ZjHRpCkglzqVKLgJ7tmpikRdrP
                                        FHc4d97LXyAk/UCcFgKI5odqMvq2779DZVgY
                                        fkqzVapZxusqIQ== )

more dsset-hn1.homenetinfra.com.
hn1.homenetinfra.com.   IN DS 2708 13 1 BFC99355ED479AA53F5976EB2B2DC9B9E1FDDE28
hn1.homenetinfra.com.   IN DS 2708 13 2 84D55D646BEFD70F47AF46C068E26F47D850986CA138A82545674056 B8CA1177



3. Publishing the Initial Homenet Zone

3.1. Publishing the zone

Manual tasks:
3.1.1. Manual copy of the signed zone to the NS

3.1.2. Manual creation of delegated zone file on the master NS in named.conf
# Our delegated zones
zone "hn1.homenetinfra.com" IN {
type master;
file "fwd.hn1.homenetinfra.com.db.signed";
allow-update { none;};
};

3.1.3. Manual creation of the slave on the slave NS in named.conf
# Our delegated zones
zone "hn1.homenetinfra.com" IN {
type slave;
file "fwd.hn1.homenetinfra.com.db.signed";
masters {92.111.140.214;};
#allow-update { none;};
};


3.1.4. Manual addition of the NS records to the parent zone on the master NS
hn1.homenetinfra.com.   IN NS ns1
hn1.homenetinfra.com.   IN NS ns2
N.B. proper delegation can't complete until the DS SET is received as the key is generated by the CPE, not the infra

Automation: NOTIFY to DM. AXFR by DM from Homenet CPE.

3.2. Adding DS Records to the Parent Zone
Manual addition of the DS SET to the parent zone on the master NS

hn1.homenetinfra.com.   IN DS 2708 13 1 BFC99355ED479AA53F5976EB2B2DC9B9E1FDDE28
hn1.homenetinfra.com.   IN DS 2708 13 2 84D55D646BEFD70F47AF46C068E26F47D850986CA138A82545674056 B8CA1177

Automation: upload DS SET RFC8078 Managing DS Records from the Parent via CDS/CDNSKEY

3.3. Signing in the new parent zone

nssec-signzone -S -K /etc/bind/keys/ -g -a  -o homenetinfra.com fwd.homenetinfra.com.db

3.4. reload the master parent zone and load the new master delegated zone

3.5. wait for NOTIFY and AXFR to do their stuff

4. CRUD on individual RR

4.1. Individual RR updates

4.2 Key Rotation

5. How to Handle Renumbering

6. Ending the Service relationship
