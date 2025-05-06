FROM fedora:latest

RUN dnf install -y curl && dnf clean all

CMD ["/bin/bash"]

