---
title: electron 설치 패키지 셋팅
categories: 
    - nodejs
tags: 
    - nodejs
    - electron
    - install package
---

**Build cross-platform desktop apps with JavaScript, HTML, and CSS**    
최근 설치형 Application 개발에 클로스 플랫폼 지원과 Javascript로 개발을 지원하는 electron의 설치형 패키지 기본 구조를 정리 합니다.   

아래 제품들이 Electron을 통해 개발된 SW Package 입니다.
- Visual Studio Code
- Facebook Messenger
- Microsoft Teams

기본적으로 Nodejs를 설치 합니다.
<https://nodejs.org/ko/download/>{:target="_blank"}

특정 디렉토리에 노드프로젝트를 설치 합니다.   

```javascript
npm init 
// index.js -> main.js로 변경한다.
// 관련 패키지 설치
npm install --save electron
npm install --save electron-builder
npm install --save--dev electron-log
npm install --save--dev electron-updater
```

package json
```json
{
    "name": "test_electron",
    "version": "1.0.0",
    "description": "",
    "main": "main.js",
    "scripts": {
        "start": "electron .",
        "test": "echo \"Error: no test specified\" && exit 1",
        "deploy": "electron-builder --win --x64 --ia32"
    },
    "keywords": [],
    "author": "",
    "license": "ISC",
    "devDependencies": {
        "electron": "8.0.0",
        "electron-builder": "22.3.2"
    },
    "dependencies": {
        "electron-log": "^4.4.1",
        "electron-updater": "^4.3.9",
        "systeminformation": "^5.9.7"
    },
    "build": {
        "productName": "HelloElectron",
        "appId": "com.electron.hello",
        "asar": true,
        "npmArgs": [
            "--production"
        ],
        "protocols": {
            "name": "helloElectron",
            "schemes": [
                "helloelectron"
            ]
        },
        "win": {
            "requestedExecutionLevel": "requireAdministrator",
            "target": [
                "zip",
                "nsis"
            ],
            "icon": "./resources/installer/default.ico"
        },
        "nsis": {
            "oneClick": false,
            "allowToChangeInstallationDirectory": true
        },
        "directories": {
            "buildResources": "./resources/installer/",
            "output": "./dist/",
            "app": "."
        }
    }
}
```



main.js
```javascript
// app모듈과, BrowserWindow 모듈 할당
const {Menu, app, BrowserWindow, ipcMain, Tray} = require('electron');


//자동 업데이트를 위해서
const { autoUpdater } = require("electron-updater");
const log = require('electron-log');


autoUpdater.logger = log;
autoUpdater.logger.transports.file.level = 'info';
log.info('App starting...');

console.log("process.platform : "+process.platform);        //process.platform : win32      darwin

let win;
let tray;

/** 메인 창 생성 */
function createMainWindow() {
    win = new BrowserWindow(
        {
            width : 800
            , minWidth:330
            , height :500
            , minHeight: 450
            , show: false
            //, icon: __dirname + '/resources/installer/Icon.ico'
            , webPreferences :  { 
                                    defaultFontSize : 14,
                                    nodeIntegration: true,  // true로 설정, Uncaught ReferenceError: require is not defined
                                    contextIsolation : false
                                }
        }
    );

    // 창이 ready 상태가되면 보여주기
    win.once('ready-to-show', function(){
        win.show();
    });

    // 윈도우 창에 로드 할 html 페이지
    win.loadURL(`file://${__dirname}/index.html`); //작은 따옴표가 아닌  back stick 기호(tab키 위)
    //__dirname : node.js 전역변수이며, 현재 실행중인 코드의 파일 경로를 나타냄

    //tray icon
    initTrayIconMenu();

    //Event 처리
    //비동기 호출
    ipcMain.on('asyncEventKey',(event, argument)=>{
        console.log("Async > RECV");
        console.log(argument);

        win.setFullScreen(true);

        setTimeout(()=>{
            event.sender.send('asyncEventKeyCb',{result:'success'}); // 비동기 메시지를 전송한다.
        },5000);
    });

    //동기 호출
    ipcMain.on('syncEventKey',(event, argument)=>{
        console.log("Sync > RECV");
        console.log(argument);

        win.setFullScreen(false);

        setTimeout(()=>{
            event.returnValue = {result:'success'} // 동기 메시지를 전송한다.
        },5000);
    });

    //개발자 도구 오픈
    win.webContents.openDevTools();
}// end fn

// Tray생성
function initTrayIconMenu(){
    tray = new Tray('./resources/installer/default.ico'); 
    const myMenu = Menu.buildFromTemplate([
      {label: '1번', type: 'normal', checked: true, click: ()=>{console.log('1번클릭!')} },  //checked는 기본선택입니다.
      {label: '2번', type: 'normal', click: ()=>{console.log('2번클릭!')}},
      {label: '3번', type: 'normal', click: ()=>{console.log('3번클릭!')}}
    ])
    tray.setToolTip('트레이 아이콘!')
    tray.setContextMenu(myMenu)
}

app.on('ready', () =>{
    createMainWindow();
    //autoUpdater.checkForUpdates(); //업데이트 체크 필요시 해당 위치에서 진행
});

app.on('window-all-closed', () => {
    app.quit();
    tray.destroy();
});

/* autoUpdater 구현시 =====================================*/
autoUpdater.on('checking-for-update', () => {
    log.info('업데이트 확인 중...');
});
autoUpdater.on('update-available', (info) => {
    log.info('업데이트가 가능합니다.');
});
autoUpdater.on('update-not-available', (info) => {
    log.info('현재 최신버전입니다.');
});
autoUpdater.on('error', (err) => {
    log.info('에러가 발생하였습니다. 에러내용 : ' + err);
});

autoUpdater.on('download-progress', (progressObj) => {
    let log_message = "다운로드 속도: " + progressObj.bytesPerSecond;
    log_message = log_message + ' - 현재 ' + progressObj.percent + '%';
    log_message = log_message + ' (' + progressObj.transferred + "/" + progressObj.total + ')';
    log.info(log_message);
})
autoUpdater.on('update-downloaded', (info) => {
    log.info('업데이트가 완료되었습니다.');
    const option = {
        type: "question",
        buttons: ["업데이트", "취소"],
        defaultId: 0,
        title: "electron-updater",
        message: "업데이트가 있습니다. 프로그램을 업데이트 하시겠습니까?",
    };
    let btnIndex = dialog.showMessageBoxSync(updateWin, option);

    if(btnIndex === 0) {
        autoUpdater.quitAndInstall();
    }    
});
```

index.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title> Electron</title>
    
</head>
<body>
    <h1> Electron!</h1>

    <button id='btnAsync'>Async send</button>
    <button id='btnSync'>Sync send</button>

    <hr>
    <button id='btnNewWin1'>window 1</button>

    <hr>
    <button id='btnClose'>Close</button>
    <script type="text/javascript" src="./render.js"></script>

</body>
</html>

```

화면측 기능을 담당하는 Script 파일    
render.js
```javascript
const {ipcRenderer} = require('electron');

const btnAsync = document.getElementById("btnAsync");
const btnSync = document.getElementById("btnSync");

const c_data =  {customdata1:1000,customdata2:'string'};

btnAsync.addEventListener('click',()=>{
    console.log("비동기 화면에서 보냄>");
    ipcRenderer.send('asyncEventKey', c_data);

});
btnSync.addEventListener('click',()=>{
    console.log("동기 화면에서 보냄>");
    let reVal = ipcRenderer.sendSync('syncEventKey', c_data);    
    console.log("동기 결과>");    
    console.log(reVal);
});


ipcRenderer.on('asyncEventKeyCb', (event, arg) => {
    console.log("비동기 결과>");    
    //console.log(JSON.stringify(event, null, 2));
    console.log(JSON.stringify(arg, null, 2));
})


///////////////////////////////////////////////////////
const electron = require('electron')
const btnWin1 = document.getElementById("btnNewWin1");

btnWin1.addEventListener('click',()=>{
    const BrowserWindow = electron.remote.BrowserWindow;
    const win = new BrowserWindow({
        height: 1080,
        width: 1920,
        show: false,
        y:0,
        x:-959,    //
        //alwaysOnTop : true,
        fullscreen : true,
        movable : true,  
        frame : false,
        //autoHideMenuBar : true
    });
    win.loadURL('https://www.naver.com');
    win.on('close', function () { win = null });
    win.once('ready-to-show', () => {
        win.show();
    });
});
```


실행하기    
```
D:\workspace_VS\test_electron>npm start

> test_electron@1.0.0 start D:\workspace_VS\test_electron
> electron .


21:43:48.094 > App starting...
process.platform : win32
(electron) The default value of app.allowRendererProcessReuse is deprecated, it is currently "false".  It will change to be "true" in Electron 9.  For more information please check https://github.com/electron/electron/issues/18397

```

![2021-10-24-electron_01.png](\assets\images_post\nodejs\2021-10-24-electron_01.png)   

패키지 빌드 하기       
```
D:\workspace_VS\test_electron>npm run deploy

> test_electron@1.0.0 deploy D:\workspace_VS\test_electron
> electron-builder --win --x64 --ia32

  • electron-builder  version=22.3.2 os=10.0.18363
  • loaded configuration  file=package.json ("build" field)
  • Specified application directory equals to project dir — superfluous or wrong configuration  appDirectory=.
  • description is missed in the package.json  appPackageFile=D:\workspace_VS\test_electron\package.json
  • writing effective config  file=dist\builder-effective-config.yaml
  • packaging       platform=win32 arch=x64 electron=8.0.0 appOutDir=dist\win-unpacked
  • downloading     url=https://github.com/electron-userland/electron-builder-binaries/releases/download/winCodeSign-2.5.0/winCodeSign-2.5.0.7z size=5.6 MB parts=1  
  • downloaded      url=https://github.com/electron-userland/electron-builder-binaries/releases/download/winCodeSign-2.5.0/winCodeSign-2.5.0.7z duration=4.44s       
  • building        target=zip arch=x64 file=dist\HelloElectron-1.0.0-win.zip
  • packaging       platform=win32 arch=ia32 electron=8.0.0 appOutDir=dist\win-ia32-unpacked
  • building        target=zip arch=ia32 file=dist\HelloElectron-1.0.0-ia32-win.zip
  • building        target=nsis file=dist\HelloElectron Setup 1.0.0.exe archs=x64, ia32 oneClick=false perMachine=false
  • downloading     url=https://github.com/electron-userland/electron-builder-binaries/releases/download/nsis-3.0.4.1/nsis-3.0.4.1.7z size=1.3 MB parts=1
  • downloaded      url=https://github.com/electron-userland/electron-builder-binaries/releases/download/nsis-3.0.4.1/nsis-3.0.4.1.7z duration=3.058s
  • building block map  blockMapFile=dist\HelloElectron Setup 1.0.0.exe.blockmap

```
패키지 완료 후 dist 폴더에 해당 설치 파일이 생성 됩니다.   

![2021-10-24-electron_02.png](\assets\images_post\nodejs\2021-10-24-electron_02.png)   

