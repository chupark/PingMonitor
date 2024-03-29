# 서버 Ping 체크
프로젝트 중 몇몇 서버들의 네트워크가 불안정한 것 같아서 스크립트를 만듬.. 


## 구성 방향
1. Windows OS에서 Ping을 위해 PSTools의 PSPing 사용
2. 데이터 수집을 위해 InfluxDB 사용
3. 한꺼번에 많은 서버를 모니터링해야 하므로 멀티쓰레드 백그라운드 job이 수행됨
4. 1초마다 Ping을 수행하여 InfluxDB API를 사용하여 데이터 Insert
5. 서버 부하를 방지하기 위해 InfluxDB 의 batch 기능을 사용함
6. 데이터 조회는 Grafana 사용


## 사용 방법
<ol>
    <li>PSTools 설치 후 Path 설정</li>
    <li>D:\PowerShell\ 디렉토리를 만든 후 Repository 복사</li>
    <li>D:\PowerShell\PingMonitor\static\servers.csv 작성</li>
    <li>D:\PowerShell\PingMonitor\static\influx.json 작성</li>
    <li>main.ps1 실행</li>
</ol>


## 주의사항
<ol>
    <li>서버 사양이 낮으면 과도한 Ping 요청, Insert 요청이 엄청난 부하를 일으킴</li>
    <ul>
        <li>InfluxDB의 batch 기능을 사용하여 부하를 줄일 수 있음</li>
    </ul>
    <li>batch Insert는 시간이 자동으로 기록되지 않음</li>
    <ul>
        <li>InfluxDB 쿼리를 해보면 batch단위마다 모아둔 데이터 중 1개 row만 Insert가 수행됐음을 확인할 수 있음</li>
        <li>이는 DateTime에 Primary Key가 걸리기 때문</li>
        <li>수집하는 서버에서 Ping 결과의 시간을 나노초(nano seconds)로 계산하여 batch를 수행해야 함</li>
    </ul>
</ol>