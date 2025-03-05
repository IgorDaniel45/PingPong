const readline = require('readline');

let ball = { x: 40, y: 12, dx: 1, dy: 1 };
let paddle1 = { y: 10 };
let paddle2 = { y: 10 };
let score1 = 0;
let score2 = 0;

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const drawField = () => {
    console.clear();
    console.log('-'.repeat(80));
    for (let i = 1; i < 24; i++) {
        console.log('|' + ' '.repeat(78) + '|');
    }
    console.log('-'.repeat(80));
};

const drawScreen = () => {
    drawField();
    process.stdout.write(`\x1b[${ball.y + 1};${ball.x + 1}H` + 'O');
    for (let i = 0; i < 4; i++) {
        process.stdout.write(`\x1b[${paddle1.y + i + 1};3H` + '|');
        process.stdout.write(`\x1b[${paddle2.y + i + 1};78H` + '|');
    }
    process.stdout.write(`\x1b[26;1HScore: ${score1} - ${score2}`);
};

const moveBall = () => {
    ball.x += ball.dx;
    ball.y += ball.dy;

    if (ball.y <= 0 || ball.y >= 24) ball.dy *= -1;
    if (ball.x <= 2 && ball.y >= paddle1.y && ball.y <= paddle1.y + 3) ball.dx *= -1;
    if (ball.x >= 77 && ball.y >= paddle2.y && ball.y <= paddle2.y + 3) ball.dx *= -1;

    if (ball.x <= 0) {
        score2++;
        ball = { x: 40, y: 12, dx: 1, dy: 1 };
    }
    if (ball.x >= 79) {
        score1++;
        ball = { x: 40, y: 12, dx: -1, dy: 1 };
    }
};

const movePaddles = (key) => {
    if (key === 'w' && paddle1.y > 0) paddle1.y--;
    if (key === 's' && paddle1.y < 20) paddle1.y++;
};

const movePaddle2 = () => {
    if (ball.y < paddle2.y && paddle2.y > 0) paddle2.y--;
    if (ball.y > paddle2.y + 3 && paddle2.y < 20) paddle2.y++;
};

const gameLoop = () => {
    moveBall();
    movePaddle2();
    drawScreen();
    setTimeout(gameLoop, 100);
};

rl.input.on('keypress', (str, key) => {
    movePaddles(key.sequence);
    if (key.sequence === '\u0003') {
        process.exit();
    }
});

console.clear();
drawField();
gameLoop();
