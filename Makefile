DRAFT:=draft-ietf-homenet-front-end-naming-delegation
VERSION:=$(shell ./getver ${DRAFT}.mkd )

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.mkd
	kramdown-rfc2629 ${DRAFT}.mkd | ./insert-figures >${DRAFT}.xml

%.txt: %.xml
	XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --text -o $@ $?

%.html: %.xml
	XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

submit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submit

cddlcheck:
	cddl front-end-configuration.cddl v front-end-configuration1.json
	cddl front-end-configuration.cddl v front-end-configuration2.json

.PRECIOUS: ${DRAFT}.xml
