from alpine
ENV HOST_FILE=/hosts/domain.list
RUN apk --no-cache add bash docker
COPY ./dnsmasq-generator.sh / 
CMD ["/dnsmasq-generator.sh", "$HOST_FILE"]
