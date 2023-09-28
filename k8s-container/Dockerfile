FROM ubuntu:22.04
RUN apt-get update && apt-get -y install curl postgresql-client jq python3.10 python3-pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY start-pqsql . 
COPY az-login-federated . 
COPY token_credential.py . 
COPY workload-ident-demo.py . 
#RUN /usr/bin/python3.10 get-pip.py