#!/bin/bash

if [ -z $1 ]; then
	sqlplus -s / as sysdba << EOF > /dev/null
SET HEAD OFF
SET TERMOUT OFF
SPOOL /tmp/asmdiskgroup.txt
SELECT  NAME FROM v\$asm_diskgroup;
SPOOL off
exit;
EOF

	DATA=($(cat /tmp/asmdiskgroup.txt))
	LAST=${DATA[${#DATA[@]} -1]}

	echo -e "{ \n \t\"data\": ["
	for i in "${DATA[@]}"; do
		if [ ${i} != ${LAST} ]; then
			echo -e '\t   { "{#ASMNAME}": "'$i'" },'
		else
			echo -e '\t   { "{#ASMNAME}": "'$i'" }'
		fi
	done
	echo -e '\t] \n}'
else
        sqlplus -s / as sysdba << EOF > /dev/null
SET HEAD OFF
SET TERM OFF
SPOOL /tmp/asmdisk.txt
SELECT  NAME, TOTAL_MB, FREE_MB FROM v\$asm_diskgroup WHERE NAME='$1';
SPOOL off
exit;
EOF
	if [ $2 == "asmname" ]; then
		echo $(awk '{ print $1 }' /tmp/asmdisk.txt)
	elif [ $2 == "asmtotal" ]; then
		echo $(awk '{ print $2 }' /tmp/asmdisk.txt)
	elif [ $2 == "asmfree" ]; then
		echo $(awk '{ print $3 }' /tmp/asmdisk.txt)
	fi
fi