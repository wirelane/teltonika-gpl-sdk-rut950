/* eslint-disable camelcase */
/* eslint-disable no-undef */
import ChilliMD5 from './ChilliMD5.js'
const md5 = new ChilliMD5()
window.md5 = md5

const path = location.pathname.split('/')
path.shift()
path.shift()
path.shift()
const page = path.join('/')
const urlParams = new URLSearchParams(window.location.search)
const uamip = urlParams.get('uamip') || ''
const uamport = urlParams.get('uamport') || ''
const userurl = urlParams.get('userurl') || ''

function trial_access() {
  const agreetos = document.getElementById('agreetos')
  let agree = ''
  if (agreetos) agree = agreetos.checked ? '&agreetos=1' : ''

  window.location = `http://${uamip}:${uamport}/trial?userurl=${encodeURIComponent(userurl)}${agree}`
}
window.trial_access = trial_access

window.addEventListener('load', function () {
  const trial_link = document.getElementById('trial_link')
  if (trial_link) {
    trial_link.addEventListener('click', function () {
      trial_access()
    })
  }

  const backbtn = document.getElementById('backbtn')
  if (backbtn) {
    backbtn.addEventListener('click', function () {
      window.history.length > 1 ? window.history.go(-1) : window.close()
    })
  }
})

function smsauthSignupRoute() {
  window.onload = function (e) {
    const form = document.querySelector('form')
    if (form == null) return

    form.onsubmit = function (e) {
      e.preventDefault()
      const formData = new FormData(e.target)
      const phone = formData.get('phone')
      window.location = `http://${uamip}:${uamport}/smssignup?phone=${encodeURIComponent(phone)}`
      return false
    }
  }
}

function smsauthLoginRoute() {
  window.onload = function (e) {
    const form = document.querySelector('form')
    if (form == null) return

    form.onsubmit = function (e) {
      e.preventDefault()
      const formData = new FormData(e.target)
      const password = formData.get('password')
      const challenge = urlParams.get('challenge')
      const agreetos = document.getElementById('agreetos')
      let agree = ''
      if (agreetos) agree = agreetos.checked ? '&agreetos=1' : ''

      const pappassword = md5.pap(challenge, password, uamsecret)
      window.location = `http://${uamip}:${uamport}/logon?username=&password=${encodeURIComponent(pappassword)}${agree}`
      return false
    }
  }
}

// --------- router -----------
switch (page) {
  case 'userpass':
    // -------- userpass / login.htm -----------
    window.onload = function (e) {
      const form = document.getElementById('login-form')
      if (form == null) return

      form.onsubmit = function (e) {
        // username and password login
        e.preventDefault()
        const formData = new FormData(e.target)
        const username = formData.get('username')
        const password = formData.get('password')
        const challenge = urlParams.get('challenge')
        const agreetos = document.getElementById('agreetos')
        let userurl = urlParams.get('userurl')
        userurl = userurl ? encodeURIComponent(userurl) : ''
        let agree = ''
        if (agreetos) agree = agreetos.checked ? '&agreetos=1' : ''

        if (auth_proto === 'pap') {
          const pw = md5.pap(challenge, password, uamsecret)
          window.location = `http://${uamip}:${uamport}/logon?username=${encodeURIComponent(username)}&password=${encodeURIComponent(pw)}&userurl=${userurl}${agree}`
        } else {
          const pw = md5.chap('00', password, challenge, uamsecret)
          window.location = `http://${uamip}:${uamport}/logon?username=${encodeURIComponent(username)}&response=${encodeURIComponent(pw)}&userurl=${userurl}${agree}`
        }
        return false
      }
    }
    break

  case 'userpass/signup':
    // -------- userpass/signup / signup.htm -----------
    window.onload = function (e) {
      const form = document.querySelector('form')
      if (form == null) return

      form.onsubmit = function (e) {
        e.preventDefault()
        // email, phone and password signup

        const formData = new FormData(e.target)

        const email = formData.get('email')
        const phone = formData.get('phone')
        const password = formData.get('password')
        const confirmPassword = formData.get('confirm_password')

        // validate values
        let valid = true
        const msg = document.getElementById('pw_msg')
        msg.classList.add('hidden')
        if (password !== confirmPassword) {
          msg.classList.remove('hidden')
          valid = false
        }

        if (!valid) return false

        window.location = `http://${uamip}:${uamport}/signup?email=${encodeURIComponent(email)}&phone=${encodeURIComponent(phone)}&password=${encodeURIComponent(password)}`

        return false
      }
    }
    break

  case 'macauth':
    // -------- macauth / login_mac.htm -----------
    window.onload = function (e) {
      const form = document.querySelector('form')
      if (form == null) return

      form.onsubmit = function (e) {
        // username and password login
        e.preventDefault()
        const formData = new FormData(e.target)
        const password = formData.get('password') || ''
        const challenge = urlParams.get('challenge')
        const agreetos = document.getElementById('agreetos')
        let agree = ''
        if (agreetos) agree = agreetos.checked ? '&agreetos=1' : ''
        let userurl = urlParams.get('userurl')
        userurl = userurl ? encodeURIComponent(userurl) : ''

        if (auth_proto === 'pap') {
          const pw = md5.pap(challenge, password, uamsecret)
          window.location = `http://${uamip}:${uamport}/logon?username=&password=${encodeURIComponent(pw)}&userurl=${userurl}${agree}`
        } else {
          const pw = md5.chap('00', password, challenge, uamsecret)
          window.location = `http://${uamip}:${uamport}/logon?username=&response=${encodeURIComponent(pw)}&userurl=${userurl}${agree}`
        }
        return false
      }
    }
    break

  case 'smsauth':
    // eslint-disable-next-line
    const res = urlParams.get('res')
    if (urlParams.get('force') === 'login') smsauthLoginRoute()
    else if (urlParams.get('force') === 'signup') smsauthSignupRoute()
    else if (urlParams.get('otpstate') === 'active') smsauthLoginRoute()
    else if (res === 'failed' || res === 'logoff' || res === 'smssuccess') smsauthLoginRoute()
    else if (res === 'notyet' || res === 'smssignup_fail') smsauthSignupRoute()
    else smsauthSignupRoute()
    break
  case 'smsauth/signup':
    smsauthSignupRoute()
    break
  case 'smsauth/login':
    smsauthLoginRoute()
    break
  default:
    break
}
