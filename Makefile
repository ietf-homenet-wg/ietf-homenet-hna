DRAFT:=draft-ietf-homenet-front-end-naming-delegation
VERSION:=$(shell ./getver ${DRAFT}.md )

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.md
	kramdown-rfc2629 -3 ${DRAFT}.md >${DRAFT}.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --v2v3 ${DRAFT}.xml
	mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.txt: %.xml
	XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --text -o $@ $?

%.html: %.xml
	XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

mysubmit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submit


