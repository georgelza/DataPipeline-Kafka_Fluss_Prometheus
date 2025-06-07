
FROM python:3.13-bookworm

USER root:root

WORKDIR /app
RUN mkdir logs
RUN mkdir conf

COPY ../requirements .

COPY *.py .
COPY .pws .

RUN pip install --upgrade pip
RUN pip install -r requirements

LABEL Author="George Leonard (georgelza@gmail.com)"

ENTRYPOINT [ "python3", "main.py" ]


