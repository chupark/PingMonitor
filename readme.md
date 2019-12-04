# 서버 Ping 체크
프로젝트 중 몇몇 서버들의 네트워크가 불안정한 것 같아서 스크립트를 만듬.. 


## 구성 방향
1. Windows OS에서 Ping을 위해 PSTools의 PSPing 사용
2. 데이터 수집을 위해 InfluxDB 사용
3. 한꺼번에 많은 서버를 모니터링해야 하므로 멀티쓰레드 백그라운드 job이 수행됨
4. 1초마다 Ping을 수행하여 InfluxDB API를 사용하여 데이터 Insert
5. 서버 부하를 방지하기 위해 InfluxDB 의 batch 기능을 사용함


## 주의사항
- 서버 사양이 낮으면 과도한 Ping 요청, Insert 요청이 엄청난 부하를 일으킴
- batch Insert는 자동으로 시간이 기록되지 않음, InfluxDB 쿼리를 해보면 모아둔 batch 데이터 중 1개만 Insert가 수행됐음을 확인할 수 있음. 이는 DateTime에 Primary Key가 걸리기 때문
- 수집하는 서버에서 Ping 결과의 시간을 나노초로 계산하여 batch를 수행해야 함
