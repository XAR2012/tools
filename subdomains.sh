while read line
do

	python3 ~/tools/OneForAll/oneforall.py --target $line run
	cat ~/tools/OneForAll/results/$line* | cut -f 7 -d ',' > ~/Desktop/$line.tmp.txt

	echo "oneforall done"

	python3 ~/tools/Sublist3r/sublist3r.py -d $line -o $line.txt
	cat /home/akshar/Desktop/$line.txt >> ~/Desktop/$line.tmp.txt

	echo "sub done"

	curl "https://dns.bufferover.run/dns?q=" | jq '.FDNS_A' | grep "," | cut -f 2 -d ',' | sed "s/\"//" >> ~/Desktop/$line.tmp.txt
	curl "https://dns.bufferover.run/dns?q=" | jq '.RDNS' | grep "," | cut -f 2 -d ',' | sed "s/\"//" >> ~/Desktop/$line.tmp.txt

	echo "bufferover done"

	amass enum --passive -d $line -json $line.json
	jq .name $line.json | sed "s/\"//g">> ~/Desktop/$line.tmp.txt

	echo "amass done"

	curl -s https://crt.sh/\?q\=\%.$line\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' >> ~/Desktop/$line.tmp.txt
	curl -s https://certspotter.com/api/v0/certs\?domain\=$line | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' >> ~/Desktop/$line.tmp.txt
	curl -s https://crt.sh/?Identity=%.$line | grep ">*.$line" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$line" | sort -u | awk 'NF' >> ~/Desktop/$line.tmp.txt

	echo "crtsh done"

	curl https://certspotter.com/api/v0/certs\?domain\=$line | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $line  >> ~/Desktop/$line.tmp.txt

	echo "cert done"


	cat ~/Desktop/tmp.txt | uniq | sort -u >> $line-uni.txt
	rm ~/Desktop/tmp.txt ~/Desktop/$line.txt ~/Desktop/$line.json

done < "${1:-/dev/stdin}"
