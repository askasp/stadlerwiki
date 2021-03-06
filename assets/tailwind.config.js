module.exports = {
  mode: 'jit',
  purge: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
 theme: {
      extend: {
      },
    },
  variants: {},
  plugins: [
      require('@tailwindcss/typography'),
      require('daisyui'),
    ],
};
