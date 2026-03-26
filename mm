<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Combo Order | 訂單管理系統</title>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <style>
        :root { --gold: #c5a358; --dark: #2c2c2c; --bg: #f4f4f7; }
        body { font-family: -apple-system, sans-serif; background: var(--bg); margin: 0; padding: 20px; display: flex; flex-direction: column; align-items: center; }
        .card { background: white; width: 100%; max-width: 400px; padding: 25px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        h2 { text-align: center; color: var(--dark); letter-spacing: 1px; }
        .section-title { font-size: 12px; color: #999; margin: 20px 0 10px; text-transform: uppercase; border-left: 3px solid var(--gold); padding-left: 8px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 15px; }
        button { padding: 15px; border: 1px solid #eee; border-radius: 12px; background: white; cursor: pointer; transition: 0.2s; font-size: 14px; }
        button.active { background: var(--dark); color: white; border-color: var(--dark); }
        .price-display { margin-top: 20px; padding: 15px; background: #fafafa; border-radius: 12px; text-align: right; border: 1px solid #f0f0f0; }
        .price-display b { font-size: 24px; color: var(--dark); }
        .submit-btn { width: 100%; margin-top: 20px; padding: 18px; background: var(--gold); color: white; border: none; border-radius: 12px; font-weight: bold; font-size: 16px; box-shadow: 0 5px 15px rgba(197, 163, 88, 0.3); }
        
        #admin-section { margin-top: 30px; width: 100%; max-width: 400px; display: none; }
        .order-card { background: white; padding: 15px; border-radius: 12px; margin-bottom: 10px; border-left: 5px solid var(--gold); box-shadow: 0 2px 5px rgba(0,0,0,0.03); }
    </style>
</head>
<body>

<div class="card" id="app">
    <h2>SIGNATURE ORDER</h2>
    
    <div class="section-title">1. 選擇豆種 BEAN</div>
    <div class="grid">
        <button class="b-bean" onclick="set('bean', '焦糖星球', 15, this)">焦糖星球 ¥15</button>
        <button class="b-bean" onclick="set('bean', '花魁', 20, this)">花魁 ¥20</button>
        <button class="b-bean" onclick="set('bean', '瑰夏', 26, this)">瑰夏 ¥26</button>
        <button class="b-bean" onclick="set('bean', '班莎', 30, this)">班莎 ¥30</button>
    </div>

    <div class="section-title">2. 飲品款式 TYPE</div>
    <div class="grid">
        <button class="b-type" onclick="set('type', '美式', null, this)">美式 Black</button>
        <button class="b-type" onclick="set('type', '拿鐵', null, this)">拿鐵 White</button>
    </div>

    <div class="section-title">3. 溫度 TEMP</div>
    <div class="grid">
        <button class="b-temp" onclick="set('temp', '冷', null, this)">冰 Iced</button>
        <button class="b-temp" onclick="set('temp', '熱', null, this)">熱 Hot</button>
    </div>

    <div class="price-display">
        <span style="font-size: 12px; color: #999;">AMOUNT: </span>
        <b>¥ <span id="total-price">0.00</span></b>
    </div>

    <button class="submit-btn" onclick="submitOrder()">確認提交點單</button>
    <p onclick="toggleAdmin()" style="text-align:center; color:var(--gold); font-size:13px; margin-top:20px; cursor:pointer; text-decoration:underline;">查看後台訂單紀錄</p>
</div>

<div id="admin-section">
    <h3 style="display:flex; justify-content:space-between;">訂單紀錄 <button onclick="loadOrders()" style="font-size:12px; padding:2px 8px;">刷新</button></h3>
    <div id="order-list">載入中...</div>
</div>

<script>
    // --- 這裡填入妳的 Supabase 資訊 ---
    const SB_URL = '你的_SUPABASE_URL';
    const SB_KEY = '你的_SUPABASE_ANON_KEY';
    const supabase = libsupabase.createClient(SB_URL, SB_KEY);

    let currentOrder = { bean: '', type: '', temp: '', price: 0 };

    function set(field, value, price, el) {
        document.querySelectorAll('.b-' + field).forEach(b => b.classList.remove('active'));
        el.classList.add('active');
        currentOrder[field] = value;
        if(price) {
            currentOrder.price = price;
            document.getElementById('total-price').innerText = price.toFixed(2);
        }
    }

    async function submitOrder() {
        if(!currentOrder.bean || !currentOrder.type || !currentOrder.temp) return alert("⚠️ 請填寫完整內容！");
        
        const { error } = await supabase.from('orders').insert([currentOrder]);
        if(error) alert("錯誤: " + error.message);
        else {
            alert("✅ 點單成功！");
            location.reload();
        }
    }

    function toggleAdmin() {
        const admin = document.getElementById('admin-section');
        admin.style.display = admin.style.display === 'none' ? 'block' : 'none';
        if(admin.style.display === 'block') loadOrders();
    }

    async function loadOrders() {
        const list = document.getElementById('order-list');
        list.innerHTML = "讀取中...";
        const { data, error } = await supabase.from('orders').select('*').order('created_at', { ascending: false });
        if(error) list.innerHTML = "無法獲取數據";
        else {
            list.innerHTML = data.map(o => `
                <div class="order-card">
                    <b>${o.bean} · ${o.type} (${o.temp})</b>
                    <div style="font-size:12px; color:#999; margin-top:5px;">
                        ¥${o.price.toFixed(2)} | ${new Date(o.created_at).toLocaleTimeString()}
                    </div>
                </div>
            `).join('');
        }
    }
</script>
</body>
</html>
