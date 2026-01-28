// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 更新 JavaScript 状态
    const jsStatus = document.getElementById('jsStatus');
    jsStatus.textContent = '✅ JavaScript 运行正常';
    
    // 获取元素
    const testBtn = document.getElementById('testBtn');
    const message = document.getElementById('message');
    const counter = document.getElementById('counter');
    
    // 点击计数器
    let count = 0;
    
    // 按钮点击事件
    testBtn.addEventListener('click', function() {
        count++;
        counter.textContent = '点击次数: ' + count;
        
        // 更新消息
        const messages = [
            '太棒了! 🎉',
            '继续点击! 🚀',
            '你真厉害! 💪',
            'JavaScript 工作正常! ✨',
            '本地站点运行完美! 🌟'
        ];
        message.textContent = messages[count % messages.length];
        
        // 添加动画效果
        testBtn.style.transform = 'scale(0.95)';
        setTimeout(function() {
            testBtn.style.transform = 'scale(1)';
        }, 100);
    });
    
    console.log('Flutter Local WebView - JavaScript loaded successfully!');
});

