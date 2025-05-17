<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><p>EECS 2070 02 Digital Design Labs 2019</p>
<p>Final Project</p>
<p>FPGA's Band</p></th>
</tr>
<tr class="odd">
<th><p>學號：107000115 姓名：林珈卉</p>
<p>學號：107062119 姓名：吳欣祐</p></th>
</tr>
</thead>
<tbody>
</tbody>
</table>

設計概念

### 功能描述

> FPGA\'s Band
> 是一個能創作音樂的編曲程式，使用者使用滑鼠點選螢幕上不同的音軌，並對該音軌進行編輯。使用者亦可選擇單獨播放該音軌、並調節音量大小，也可以同時播放全部的音軌所合成的音樂。
>
> 我們提供使用者4個音軌，第一個為音色為電音鍵盤樂器的主旋律，占用1個音道；第二個是音色為鋼琴的和絃背景，因為需要3個音高才能組成一個和絃，故占用3個音道；第三個為音色為貝斯的旋律，占用1個音道；第四個為音色為打擊樂器的節奏，占用1個音道。
>
> ![一張含有 室內, 坐, 白色, 黑色 的圖片
> 自動產生的描述](media/image18.png){width="5.471307961504812in"
> height="3.182292213473316in"}

### 靈感來源

> 我們的創作靈感來自於 Google 所提供的簡易網頁編曲軟體「CHROME MUSIC
> LAB: SONG
> MAKER」，該程式可以編輯四個小節的音樂，可以選擇多種音色，音高範圍則為兩個八度（不含黑鍵部分），節奏也有多種音色，每種音色有兩個音效。
>
> 而我們希望使用硬體語言來實作出相似功能的程式，並加上額外的功能。如增加可編輯的音高（含有黑鍵，總共25個音），及增加和絃輸入的功能，讓樂曲可以在和絃架構的基礎下來編輯音樂，還有各種樂器分佈獨立的編輯環境與獨立音軌的播放功能。
>
> ![](media/image4.png){width="6.270833333333333in"
> height="3.3194444444444446in"}

架構細節及方塊圖

### 架構細節------畫面

<table>
<colgroup>
<col style="width: 18%" />
<col style="width: 38%" />
<col style="width: 42%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>畫面</strong></th>
<th><strong>功能／畫面</strong></th>
<th><strong>細節</strong></th>
</tr>
<tr class="odd">
<th>主畫面</th>
<th><p>顯示四種樂器</p>
<p>點選可進入該樂器的編輯模式</p></th>
<th><p>鋼琴：顯示大致旋律音高</p>
<p>貝斯：顯示大致旋律音高</p>
<p>吉他：顯示每小節和絃名稱</p>
<p>打擊：顯示大、小鼓（不同符號）</p></th>
</tr>
<tr class="header">
<th>鋼琴主旋律</th>
<th><p>橫軸為時間軸</p>
<p>縱軸為音高</p></th>
<th><p>橫軸以八分音符為單位</p>
<p>縱軸總共有兩個八度（25個音）</p></th>
</tr>
<tr class="odd">
<th>吉他和絃</th>
<th><p>上方選擇和絃</p>
<p>下方為時間軸</p></th>
<th><p>以一小節為單位，共四個小節</p>
<p>總共 2*12 種和絃</p>
<p>（大、小 2 種和絃，12 個根音）</p>
<p>例：C、Cm、C#、C#m</p></th>
</tr>
<tr class="header">
<th>貝斯旋律</th>
<th><p>橫軸為時間軸</p>
<p>縱軸為音高</p></th>
<th><p>橫軸以八分音符為單位</p>
<p>縱軸總共有兩個八度（25個音）</p></th>
</tr>
<tr class="odd">
<th>打擊樂器</th>
<th><p>橫軸為時間軸</p>
<p>縱軸為樂器種類</p>
<p>非獨立畫面，於主畫面編輯</p></th>
<th><p>橫軸以八分音符為單位</p>
<p>縱軸有兩種音色，大鼓與小鼓</p></th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### 

###   {#section-1}

### 架構細節------ IO Devices

<table>
<colgroup>
<col style="width: 33%" />
<col style="width: 66%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>I/O</strong></th>
<th><strong>描述</strong></th>
</tr>
<tr class="odd">
<th>Switch</th>
<th>SW0: rst</th>
</tr>
<tr class="header">
<th>LED</th>
<th>LED0~LED4: 音量大小顯示</th>
</tr>
<tr class="odd">
<th>Push button</th>
<th><p>BTNU:音量增大</p>
<p>BTND:音量減小</p>
<p>BTNL:播放音樂／暫停播放</p>
<p>BTNR:回主畫面</p>
<p>BTNC:停止播放<img src="media/image20.png"
style="width:2.91557in;height:2.90104in" /></p></th>
</tr>
<tr class="header">
<th>7-Segment Display</th>
<th>顯示當前主旋律音高（例：A4）</th>
</tr>
<tr class="odd">
<th>Mouse</th>
<th>搭配螢幕，讓使用者輸入音樂、音高</th>
</tr>
<tr class="header">
<th>VGA</th>
<th>輸出螢幕訊號</th>
</tr>
<tr class="odd">
<th>Audio Amplifier</th>
<th>播放音樂</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

### 方塊圖

![](media/image10.jpg){width="6.270833333333333in"
height="3.5277777777777777in"}

實作方法及難易度說明

<table>
<colgroup>
<col style="width: 13%" />
<col style="width: 15%" />
<col style="width: 71%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>項目</strong></th>
<th><strong>細項</strong></th>
<th><strong>實作方法</strong></th>
</tr>
<tr class="odd">
<th rowspan="5">音色實作</th>
<th>音高與頻率</th>
<th><ul>
<li><blockquote>
<p>從滑鼠端輸入音高訊號，為音高的編號（主旋律的中央 C 為編號 1，C#
為編號 2 等）</p>
</blockquote></li>
<li><blockquote>
<p>將編號透過 Note_Decoder module 轉換成頻率的數值，並傳回 speaker
module</p>
</blockquote></li>
<li><blockquote>
<p>Note_Decoder 如下圖，每個音軌皆有一組 Decoder</p>
</blockquote></li>
</ul>
<p><img src="media/image19.png"
style="width:1.78991in;height:3.67188in" /></p>
<ul>
<li><blockquote>
<p>根據頻率的數值，計算每一個週期的 clk 數量</p>
</blockquote></li>
<li><blockquote>
<p>再配合音色，從 note_gen 輸出訊號給 speaker_control</p>
</blockquote></li>
</ul>
<p>實作範例</p>
<ol type="1">
<li><blockquote>
<p>如中央 A 為 440Hz</p>
</blockquote></li>
<li><blockquote>
<p>每 100000000/440 個 clk 為一個波形週期</p>
</blockquote></li>
<li><blockquote>
<p>主旋律音色，每一個週期的取樣點總共有42個</p>
</blockquote></li>
<li><blockquote>
<p>將取樣點的數值列成陣列（數列命名 w1, w2, w3...）</p>
</blockquote></li>
<li><blockquote>
<p>audio_right 等訊號每經過 (100000000/440)/42 個 clk
會改變至下一個數值（從 w1 變成 w2）</p>
</blockquote></li>
</ol></th>
</tr>
<tr class="header">
<th>音色波形</th>
<th><ol type="1">
<li><blockquote>
<p>將該音色的音檔輸入 Sonic Visualiser 程式</p>
</blockquote></li>
</ol>
<blockquote>
<p><img src="media/image6.png"
style="width:2.94271in;height:1.58335in" /></p>
</blockquote>
<ol start="2" type="1">
<li><blockquote>
<p>取用中段的訊號波形，因前段的波形含有觸鍵的音色，較為混雜，無法使用；後段的音色則逐漸消逝，泛音音色明顯突出</p>
</blockquote></li>
</ol>
<blockquote>
<p><img src="media/image9.png"
style="width:3.00521in;height:1.4119in" /></p>
<p><img src="media/image8.png"
style="width:3.0625in;height:0.89583in" /></p>
</blockquote>
<ol start="3" type="1">
<li><blockquote>
<p>取用一個週期的波形，紀錄每個取樣點的數值</p>
</blockquote></li>
</ol>
<blockquote>
<p><img src="media/image5.png"
style="width:2.36782in;height:2.74479in" /></p>
</blockquote>
<ol start="4" type="1">
<li><blockquote>
<p>使用 2’s Complement 的格式儲存 16 bit
的數值陣列，下圖為鍵盤樂器的音色，共有 42 個取樣點</p>
</blockquote></li>
</ol>
<blockquote>
<p><img src="media/image3.png"
style="width:3.3125in;height:1.96875in" /></p>
</blockquote></th>
</tr>
<tr class="odd">
<th>打擊樂器</th>
<th><p>使用 sine
函數，音高從高頻率迅速降至低頻率，製造出打擊樂器的效果。</p>
<p>下圖為大鼓的頻率變化，及兩種鼓在調整 EQ
時，各頻率分布的可用性分析。大鼓頻率的可用範圍約為 20 至 200Hz，小鼓則為
150 至 250Hz。</p>
<p><img src="media/image1.png"
style="width:3.96875in;height:2.04167in" /></p>
<p><img src="media/image7.png"
style="width:3.96354in;height:1.28387in" /></p>
<p><img src="media/image14.png"
style="width:3.96875in;height:2.375in" /></p>
<p><img src="media/image15.png"
style="width:3.96875in;height:2.38889in" /></p></th>
</tr>
<tr class="header">
<th>和絃訊號</th>
<th>輸入此 module 的和絃訊號數值範圍為 0~23，分別代表 24
種和絃，因此我們需要 Note_Decoder 去把和絃訊號拆解為 3
個單音的頻率訊號。</th>
</tr>
<tr class="odd">
<th>ADSR 實作</th>
<th><ul>
<li><blockquote>
<p>為了製造出更像真實樂器所發出的音色，必須加上「觸鍵」以及「漸出」的效果，而這個部分可以應用到混音學的
ADSR 理論。</p>
</blockquote></li>
<li><blockquote>
<p>ADSR 包含 Attack、Decay、Sustain 以及 Release，我使用 FSM
來實作這個部分。</p>
</blockquote></li>
<li><blockquote>
<p>reg [1:0] 變數命名為 ADSR，數值為 2’b00 時為 A state，2’b01 時為 D
state，2’b10 時為 S state，2’b11 時為 R state。</p>
</blockquote></li>
<li><blockquote>
<p>reg 變數 rate 為音量的倍率，用來控制 audio_left
等變數所輸出的數值。</p>
</blockquote></li>
<li><blockquote>
<p>每個 state 的功能</p>
</blockquote>
<ul>
<li><blockquote>
<p>A state</p>
</blockquote>
<ul>
<li><blockquote>
<p>next_rate = rate + 1</p>
</blockquote></li>
<li><blockquote>
<p>if (rate &gt;= 10) next_ADSR = D</p>
</blockquote></li>
</ul></li>
<li><blockquote>
<p>D state</p>
</blockquote>
<ul>
<li><blockquote>
<p>next_rate = rate - 1</p>
</blockquote></li>
<li><blockquote>
<p>if (rate &lt;= 7) next_ADSR = S</p>
</blockquote></li>
</ul></li>
<li><blockquote>
<p>S state</p>
</blockquote>
<ul>
<li><blockquote>
<p>使用 counter 來計算 S state 的時間長度</p>
</blockquote></li>
<li><blockquote>
<p>if (ADSR_cnt &gt; 20) next_ADSR = R</p>
</blockquote></li>
</ul></li>
<li><blockquote>
<p>R state</p>
</blockquote>
<ul>
<li><blockquote>
<p>if (rate &gt; 0) next_rate = rate - 1</p>
</blockquote></li>
</ul></li>
</ul></li>
</ul>
<p><img src="media/image17.png"
style="width:3.44271in;height:3.72282in" /></p></th>
</tr>
<tr class="header">
<th rowspan="4">螢幕顯示</th>
<th>圖片顯示</th>
<th>我使用 block memory generator 的 IP 來儲存我在project
中所需要用到的圖片，並且透過控制 memory address
來決定要輸出的訊號。</th>
</tr>
<tr class="odd">
<th>框線</th>
<th>在此 project 中的表格框線都是經由判定 h_cnt, v_cnt
的值來決定的，也因此框線並不會消耗記憶體的資源。</th>
</tr>
<tr class="header">
<th>音樂播放</th>
<th><p><img src="media/image13.png"
style="width:3.96875in;height:1.94444in" /></p>
<p>我使用了 FSM 來控制音樂播放，state transition graph 如上圖，另外 FSM
也會輸出 play_cnt 訊號，這個訊號代表當前播放到第幾個 8 分音符，會在 vga
顯示上用到。</p></th>
</tr>
<tr class="odd">
<th>旋律儲存</th>
<th>我選擇使用 register 來儲存旋律，原因是因為簡單好實作、且只需要 1 個
clock cycle 便能儲存，也可以直接存取使用。</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

分工

<table>
<colgroup>
<col style="width: 15%" />
<col style="width: 26%" />
<col style="width: 58%" />
</colgroup>
<thead>
<tr class="header">
<th></th>
<th><strong>Modules</strong></th>
<th><strong>詳細內容</strong></th>
</tr>
<tr class="odd">
<th>林珈卉</th>
<th><p>speaker</p>
<p>Note_Decoder</p>
<p>note_gen</p>
<p>speaker_control</p></th>
<th><p>實作音色、音高控制</p>
<p>根據音高訊號轉換成頻率以及音色</p>
<p>輸出聲音訊號</p></th>
</tr>
<tr class="header">
<th>吳欣祐</th>
<th><p>Mouse</p>
<p>pixel_gen</p>
<p>vga</p>
<p>數個 ip</p></th>
<th><p>處理使用者輸入的滑鼠訊號</p>
<p>轉換成音高訊號，傳遞至 speaker module</p>
<p>輸出螢幕畫面的訊號</p></th>
</tr>
</thead>
<tbody>
</tbody>
</table>

##   {#section-2}

## 困難與解決方法

- 在 pixel_gen module 中我發現圖片最左側兩個 pixel
  > 無法正常顯示，會有黑點不斷跳動，因為找不到此問題的成因，因此我的解決方法為直接將最左兩個
  > pixel 設為白色。

- Speaker 實作

  - 在 note_gen 的 ADSR FSM
    > 中，需要判斷是否有新的音輸入，若是以輸入的音高數值與前者不同來作為判斷依據，就無法連續播放兩個相同的音高。因此需要輸入一個
    > input 訊號命名為 newpulse，assign 為 (freq !=
    > \`silence)。使用相同頻率的 clk ，在 FSM 更新的 always block
    > 中判斷若 new_pulse == 1，next_ADSR = A，next_rate = init_val。

  - 在 note_gen module 中需要對 audio_right 等變數賦值，這些變數為 2's
    > complement 的格式，因此音色的數值陣列也必須為 2's
    > complement。而數值會根據 rate 乘上倍率，所以 rate 也必須為 2's
    > complement。也可選擇在 always block 賦值時，變數前面加上 \$signed
    > 即可。

  - Speaker module 需要輸出六個音道的訊號，因此要將 master
    > clock、left-right clock、serial clock 及 audio_sdin
    > 這四個訊號複製為三份，並連接到三個 Pmod 晶片上。

## 心得討論

- 吳欣祐

> 我覺得 pixel_gen module 就技術層面來說不會很困難，因為將前面 lab
> 教的東西靈活運用便能完成，反之讓我比較吃力的是在處理表格和圖片上比較龐雜繁大的工作量。![](media/image16.png){width="3.2997528433945758in"
> height="1.953125546806649in"}

- 林珈卉

> 很高興能在這次的 Final Project
> 中發揮我過去所學的知識，及實作出一個跟我喜歡的領域相關的作品，也謝謝這堂課程、教授、助教們提供這個機會。
>
> 過去有些編曲和混音的經驗，使用的是 macOS 的 Logic Pro 軟體。在設計這個
> FPGA's Band 時，除了上面介紹的網頁版編曲程式外，也有參考一些 Logic Pro
> X 的介面、輸入格式等等。
