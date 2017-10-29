## Source:
## Command line reference for editing quotas
## Post by rhodie » Fri Nov 29, 2013 4:07 am 
## https://www.gargoyle-router.com/phpbb/viewtopic.php?f=12&t=5056
## Add to /etc/crontabs/root. 
## ISP's quota resets on the 14th of each month, and I want user 1 to get 1/ 7 of the quota and users 2-4 to get 2/7 each.

# Total limit
TOTAL_LIMIT=`uci get firewall.quota_1.combined_limit`
# echo Total limit: $TOTAL_LIMIT

# Days left
DAY=`date +%d`
MONTH=`date +%m`
YEAR=`date +%Y`
if [ $DAY -gt 13 ]; then
        MONTH=$(($MONTH + 1))
        if [ $MONTH -eq 13 ]; then
                MONTH='01'
                YEAR=$(($YEAR + 1))
        fi
fi
DAYS_LEFT=$(( ( $(date -d "$YEAR-$MONTH-14 0:00" "+%s") - $(date "+%s") ) / 86400 + 1))
# echo Days left: $DAYS_LEFT

# Used so far
USED_SO_FAR=`print_quotas | grep quotaUsed | egrep -o '=.+' | egrep -o ' [0-9]+,' | egrep -o '[0-9]+' | head -n1`
# echo Used so far: $USED_SO_FAR

# Amount remaining
AMOUNT_REMAINING=$(($TOTAL_LIMIT - $USED_SO_FAR))
# echo Amount remaining: $AMOUNT_REMAINING

# Per user
ONE_SEVENTH=$(($AMOUNT_REMAINING / $DAYS_LEFT / 7))
TWO_SEVENTHS=$((ONE_SEVENTH * 2))
# echo 1/7: $ONE_SEVENTH
# echo 2/7: $TWO_SEVENTHS

# Set the limits
uci set firewall.quota_2.combined_limit=$ONE_SEVENTH
uci set firewall.quota_3.combined_limit=$TWO_SEVENTHS
uci set firewall.quota_4.combined_limit=$TWO_SEVENTHS
uci set firewall.quota_5.combined_limit=$TWO_SEVENTHS
