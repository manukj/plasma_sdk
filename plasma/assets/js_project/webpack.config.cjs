const path = require('path');
const webpack = require('webpack');

module.exports = {
    mode: 'production',
    entry: './index.js', // Our source code
    output: {
        path: path.resolve(__dirname, '../www'), // Output to the Flutter assets folder
        filename: 'bundle.js',
    },
    resolve: {
        fallback: {
            buffer: require.resolve('buffer/'),
        },
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                type: 'javascript/auto',
            },
        ],
    },
    plugins: [
        new webpack.ProvidePlugin({
            Buffer: ['buffer', 'Buffer'], // Auto-inject Buffer polyfill
        }),
    ],
    experiments: {
        outputModule: false,
    },
};
