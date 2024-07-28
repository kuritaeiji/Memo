FROM elasticsearch:7.6.2

RUN bin/elasticsearch-plugin install analysis-kuromoji

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["elasticsearch"]