const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
    entry: {
        bundle: './app/index',
        style: './app/style'
    },
    output: {
        path: __dirname + '/dist',
        filename: '[name].js'
    },
    resolve: {
        extensions: ['.elm', '.js', '.scss'],
    },
    module: {
        rules: [
            {test: /\.elm/, exclude: /node_modules|elm-stuff/, loader: 'elm-webpack-loader'},
            {test: /\.scss$/, exclude: /node_modules/, loader: ExtractTextPlugin.extract(['css-loader?sourceMap', 'sass-loader?sourceMap'])},
        ],
    },
    plugins: [
        new ExtractTextPlugin('style.css'),
    ],
};
