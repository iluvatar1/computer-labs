#!/bin/bash
if -f /opt/netdata/bin/netdatacli; then
    echo "netdata already installed"
    exit 0
fi

#CLAIM_TOKEN=cbEv8Eg4o6JOxSKfOMhUtNcu0kuxnRus6JhhgTI9juW7II1_b_lYGPsB17Xsj9ZxXnRxY4yrkrT9ip0EChpM0REIHvPBd4mjfmwuObzK3F2hI6BArgXsX6zobAWCLDAyGg9hht0
#ROOM_ID=90d89638-c88c-41ef-8b71-8503e24d6f8a
# --dry-run
#EXTRA_FLAGS="--build-only   --non-interactive  --stable-channel --no-updates --install-prefix /opt "
#EXTRA_FLAGS="--static-only   --non-interactive  --stable-channel --no-updates "
#wget -c -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && MAKEOPTS="-j$(nproc)" sh /tmp/netdata-kickstart.sh $EXTRA_FLAGS --claim-token $CLAIM_TOKEN #--claim-rooms=$ROOM_ID -url=https://app.netdata.cloud -id=$(uuidgen)

# from netdata 2024-07-09
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --nightly-channel --claim-token Y3H6y77CfIWDF1dDc0r-GDwkcRPaVS-PnWQ1lG2wGPYh407KYQEk6_cOckynwqss8T9BRCX1DlqUwjsiziRUxomN0iklS-BQfNvX59bETYwutvUZR89zpsMtf3QpsxEuUJ6-QkM --claim-rooms 928d0e30-05a1-4bf9-a512-3a27f6eea378 --claim-url https://app.netdata.cloud --static-only --non-interactive --claim-id $(uuidgen)
