# 1.Download the package
```
wget -c https://mirrors.aliyun.com/docker-ce/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_18.03.1~ce-0~debian_amd64.deb

```
# 2.Install the software.
```
sudo dpkg -i docker-ce_18.03.1~ce-0~debian_amd64.deb
```
# 3.Modify microsoft users and add the users to the docker group.
```
sudo usermod microsoft_duruihong -aG docker
sudo usermod microsoft_fuxiao -aG docker
sudo usermod microsoft_chenxiaoyang -aG docker
```
# 4.Start and enable the docker daemon .
```
sudo systemctl start docker
sudo systemctl enable docker
```
