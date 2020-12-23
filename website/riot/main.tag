<main>
  <div class="container">
		<header is="header" ref="header" authorized={ this.state.authorized } username={ this.state.username } log-out={ logOut } show-dict-menu={ this.state.showDictMenu } dict-id={ this.dictId } user-access={ this.state.userAccess }></header>
		<div class="content row" is={ this.content } dict-id={ this.dictId} authorized={ this.state.authorized } check-auth={ checkAuth } entry-id={ this.entryId } load-dict-detail={ loadDictDetail } load-config-data={ loadConfigData } save-config-data={ saveConfigData } dict-details={ this.state.dictDetails } config-id={ this.configId }></div>
		<footer is="footer"></footer>
  </div>

  <script>
		export default {
			content: '',
			checkingAuth: false,
			dictId: '',
			state: {
				authorized: false,
				username: '',
				userAccess: false,
				dictDetails: {},
				showDictMenu: false,
				publicMoreEntries: [],
			},

			getCookie(val) {
				return document.cookie.split('; ').find(row => row.startsWith(val+'=')).split('=')[1].slice(1,-1);
			},

			checkAuth() {
				var email = $('#username').val();
				var password = $('#password').val();
				$.post("/login.json", {email: email, password: password}, (response) => {
					if (response.success) {
						this.state.username = this.getCookie('email');
						this.state.authorized = true;
					}
				}).always(() => {
					this.checkingAuth = false;
					this.update();
				})
			},

			logOut() {
				this.state.authorized = false;
				this.state.username = '';
				this.state.showDictMenu = false;
				this.state.userAccess = false;
				$.post("/logout.json", {}, (response) => {
				}).always(() => {
					this.checkingAuth = false;
					this.update();
				})
			},

			loadDictDetail() {
				$.get("/" + this.dictId + "/config.json", (response) => {
					console.log(response);
					if (response.success) {
						this.state.dictDetails.title = response.publicInfo.title;
						this.state.dictDetails.blurb = response.publicInfo.blurb;
						this.state.dictDetails.public = response.publicInfo.public;
						this.state.dictDetails.licence = response.publicInfo.licence;
						this.state.dictDetails.xemaOverride = false;
						this.state.dictDetails.xemplateOverride = false;
						this.state.dictDetails.editingOverride = false;
						this.state.userAccess = response.userAccess;
						if (response.userAccess != false && (response.userAccess.canEdit || response.userAccess.canConfig || response.userAccess.canDownload || response.userAccess.canUpload)) {
							this.state.showDictMenu = true;
						}
						this.update();
					} else {
						route("/");
					}					
				});
			},

			loadConfigData(configId) {
				console.log('load config')
				return new Promise((resolve) => {
					$.post("/" + this.dictId + "/configread.json", {id: configId}, (response) => {
						resolve(response.content)
					});
				});
			},

			saveConfigData(configId, data) {
				$.post("/" + this.dictId + "/configupdate.json", {id: configId, content: JSON.stringify(data)}, (response) => {
					console.log(response)
					$('#submit_button').html('Saved...');
					setTimeout(() => {$('#submit_button').html('Save <i class="material-icons right">save</i>');}, 2000);
				});
			},

			onUpdated() {
				console.log('content='+this.content)
			},

			onMounted() {
				this.state.authorized = true;
				this.state.username = 'rambousek@gmail.com';

				console.log('mount')
				route('/*/edit', (dictId) => {
					console.log('edit ' + dictId)
					this.dictId = dictId;
					this.update();
				});
				route('/*/([0-9]*)', (dictId, entryId) => {
					console.log('public entry ' + dictId + '-' + entryId)
					this.dictId = dictId;
					this.entryId = entryId;
					this.content = 'dict-public-entry';
					this.update();
				});
				route('/*/config/*', (dictId, configId) => {
					console.log('config ' + dictId)
					this.dictId = dictId;
					this.configId = configId;
					this.content = 'dict-config-'+configId;
					this.update();
				});
				route('/*/config', (dictId) => {
					console.log('config ' + dictId)
					this.dictId = dictId;
					this.content = 'dict-config';
					this.update();
				});
				route('/*', (dictId) => {
					console.log('testd ' + dictId)
					this.dictId = dictId;
					this.content = 'dict-public';
					this.update();
				});
				route('/', () => {
					console.log('main')
					this.dictId = '';
					this.state.showDictMenu = false;
					this.state.userAccess = false;
					this.content = 'main-page';
					this.update();
				});
				route.start(true);
			}
		}
	</script>
</main>