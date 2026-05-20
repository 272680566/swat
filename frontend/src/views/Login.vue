<template>
  <div class="login-wrapper">
    <div class="login-card">
      <h2 class="login-title">SWAT 系统登录</h2>

      <div class="tabs">
        <span :class="{ active: isLogin }" @click="isLogin = true">登录</span>
        <span :class="{ active: !isLogin }" @click="isLogin = false">注册</span>
      </div>

      <form v-if="isLogin" @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label>用户名</label>
          <input v-model="loginForm.username" type="text" placeholder="请输入用户名" />
        </div>
        <div class="form-group">
          <label>密码</label>
          <input v-model="loginForm.password" type="password" placeholder="请输入密码" />
        </div>
        <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>
        <button type="submit" :disabled="loading" class="btn-primary">
          {{ loading ? '登录中...' : '登 录' }}
        </button>
      </form>

      <form v-else @submit.prevent="handleRegister" class="login-form">
        <div class="form-group">
          <label>用户名</label>
          <input v-model="registerForm.username" type="text" placeholder="请输入用户名" />
        </div>
        <div class="form-group">
          <label>邮箱</label>
          <input v-model="registerForm.email" type="email" placeholder="请输入邮箱" />
        </div>
        <div class="form-group">
          <label>密码</label>
          <input v-model="registerForm.password" type="password" placeholder="请输入密码" />
        </div>
        <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>
        <button type="submit" :disabled="loading" class="btn-primary">
          {{ loading ? '注册中...' : '注 册' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import { login, register } from '../api'

export default {
  name: 'LoginView',
  data() {
    return {
      isLogin: true,
      loading: false,
      errorMsg: '',
      loginForm: { username: '', password: '' },
      registerForm: { username: '', email: '', password: '' }
    }
  },
  methods: {
    async handleLogin() {
      this.errorMsg = ''
      if (!this.loginForm.username || !this.loginForm.password) {
        this.errorMsg = '用户名和密码不能为空'
        return
      }
      this.loading = true
      try {
        const res = await login(this.loginForm.username, this.loginForm.password)
        if (res.data.success) {
          this.$router.push('/home')
        } else {
          this.errorMsg = res.data.message
        }
      } catch {
        this.errorMsg = '网络错误，请稍后重试'
      } finally {
        this.loading = false
      }
    },
    async handleRegister() {
      this.errorMsg = ''
      if (!this.registerForm.username || !this.registerForm.password) {
        this.errorMsg = '用户名和密码不能为空'
        return
      }
      this.loading = true
      try {
        const res = await register(
          this.registerForm.username,
          this.registerForm.password,
          this.registerForm.email
        )
        if (res.data.success) {
          this.loginForm.username = this.registerForm.username
          this.registerForm = { username: '', email: '', password: '' }
          this.isLogin = true
          this.errorMsg = ''
        } else {
          this.errorMsg = res.data.message
        }
      } catch {
        this.errorMsg = '网络错误，请稍后重试'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.login-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}

.login-card {
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  width: 400px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
}

.login-title {
  text-align: center;
  color: #333;
  margin-bottom: 24px;
  font-size: 22px;
}

.tabs {
  display: flex;
  border-bottom: 2px solid #eee;
  margin-bottom: 24px;
}

.tabs span {
  flex: 1;
  text-align: center;
  padding: 10px 0;
  cursor: pointer;
  color: #999;
  transition: color 0.2s, border-color 0.2s;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
}

.tabs span.active {
  color: #667eea;
  border-bottom-color: #667eea;
  font-weight: 600;
}

.login-form .form-group {
  margin-bottom: 18px;
}

.login-form label {
  display: block;
  margin-bottom: 6px;
  color: #555;
  font-size: 14px;
}

.login-form input {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s;
}

.login-form input:focus {
  border-color: #667eea;
}

.error-msg {
  color: #e74c3c;
  font-size: 13px;
  margin-bottom: 12px;
  text-align: center;
}

.btn-primary {
  width: 100%;
  padding: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: opacity 0.2s;
}

.btn-primary:hover {
  opacity: 0.9;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
