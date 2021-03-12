FROM python:3.7.2-alpine3.8
RUN mkdir /proj
COPY 4-task/pyproject/jsonproc.py /proj/jsonproc.py
WORKDIR /proj
EXPOSE 8080
COPY 5-task/docker/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
CMD ["python", "jsonproc.py"]