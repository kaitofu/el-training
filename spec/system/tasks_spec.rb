require 'rails_helper'

describe 'タスク管理機能', type: :system do
	describe '一覧表示機能' do
		let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }    
		let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }    
		
		before do
			admin = FactoryBot.create(:user, admin: true)
		end

		describe 'ログイン機能' do
			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "最初のタスク", user: user_a)
					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'
				end
		
				it 'ユーザAが作成したタスクが表示される' do 
					expect(page).to have_content '最初のタスク'
				end
			end

			context 'ユーザBがログインしているとき' do
				let(:login_user) { user_b }
				before do
					FactoryBot.create(:task, name: "最初のタスク", user: user_a)
					visit login_path
					fill_in 'メールアドレス',  with: login_user.email
					fill_in 'パスワード', with: login_user.password
					click_button 'ログインする'
				end

				it 'ユーザAが作成したタスクが表示されない' do 
					expect(page).not_to have_content '最初のタスク'
				end
			end
		end
		
		describe '並べ替え機能' do 
			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "1番目", user: user_a, created_at: Time.current + 2.days )
					FactoryBot.create(:task, name: "2番目", user: user_a, created_at: Time.current + 1.days )
					FactoryBot.create(:task, name: "3番目", user: user_a, created_at: Time.current)

					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'
				end
		
				it 'ユーザAが作成したタスクが作成日時の降順に表示される' do 
					within '.table' do
						task_names = all('.name').map(&:text)
						expect(task_names).to eq %w(1番目 2番目 3番目) 
					end
				end
			end

			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "1番目", user: user_a, deadline: Date.today )
					FactoryBot.create(:task, name: "2番目", user: user_a, deadline: Date.today + 1.days )
					FactoryBot.create(:task, name: "3番目", user: user_a, deadline: Date.today + 2.days )

					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'
					click_on '期限'
				end
		
				it 'ユーザAが作成したタスクが期限の昇順に表示される' do 
					within '.table' do
						task_deadlines = all('.deadline').map(&:text)
						expect_deadlines = []
						expect_deadlines << Date.today.to_s
						expect_deadlines << Date.today.succ.to_s
						expect_deadlines << Date.today.succ.succ.to_s
						expect(task_deadlines).to eq expect_deadlines 
					end
				end
			end
		end

		describe 'タスク検索機能' do
			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "1番目", user: user_a, priority: 2)
					FactoryBot.create(:task, name: "2番目", user: user_a, priority: 1)
					FactoryBot.create(:task, name: "3番目", user: user_a, priority: 0)

					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'
					click_on '優先度'
				end
		
				it 'ユーザAが作成したタスクが優先順位の昇順に表示される' do 
					within '.table' do
						task_names = all('.name').map(&:text)
						expect(task_names).to eq %w(3番目 2番目 1番目) 
					end
				end

				it 'ユーザAが作成したタスクが優先順位の降順に表示される' do 
					click_on '優先度'
					within '.table' do
						task_names = all('.name').map(&:text)
						expect(task_names).to eq %w(1番目 2番目 3番目) 
					end
				end
			end
	
			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "first", user: user_a, priority: 2, status: "未着手")
					FactoryBot.create(:task, name: "second", user: user_a, priority: 1, status: "着手中")
					FactoryBot.create(:task, name: "third", user: user_a, priority: 0, status: "完了")
					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'

					fill_in '名称', with: 'first'
					click_button 'Search'
				end
		
				it 'タスク「first」が表示される' do 
					expect(page).to have_content "first"
				end
			end
			
			context 'ユーザAがログインしているとき' do
				before do
					FactoryBot.create(:task, name: "first", user: user_a, priority: 2, status: "未着手")
					FactoryBot.create(:task, name: "second", user: user_a, priority: 1, status: "着手中")
					FactoryBot.create(:task, name: "third", user: user_a, priority: 0, status: "完了")
					visit login_path
					fill_in 'メールアドレス',  with: 'a@example.com'
					fill_in 'パスワード', with: 'password'
					click_button 'ログインする'

					select '未着手', from: '進捗'
					click_button 'Search'
				end
				
				it 'ユーザAが作成したタスクが優先順位の降順に表示される' do 
					expect(page).to have_content "first"
				end
			end
		end

		describe 'タスク新規登録機能' do
			context '新規作成画面で名前を入力したとき' do
				it '正常に登録される' do
					#FIXME
				end
			end
			
			context '新規作成画面で名前を入力しなかったとき' do
				it '登録に失敗する' do
					#FIXME
				end
			end
		end

		describe 'タスク編集機能' do
			before do
					#編集対象のタスクを作成
					#ログイン
					#編集ボタン押下
			end

			it 'タグが追加できること' do
					#タグを入力
					#更新ボタン押下
					#そのタグを含むタスクが登録されている
			end 

			it 'タグが削除できること' do
					#タグを入力
					#更新ボタン押下
					#そのタグを含むタスクが一覧に存在しない
			end 

			it '削除したタスクのラベルのうちどのタスクにも紐付かなくなるものは削除されていること'do
			#FIXME
			end
		end

		describe 'タスク削除機能' do
			before do
					#削除対象のタスクを作成
					#ログイン
					#削除ボタン押下
			end

			it 'ユーザAが作成したタスクが削除されている' do
					#FIXME
			end

			it '削除したタスクのラベルのうちどのタスクにも紐付かなくなるものは削除されていること'do
					#FIXME
			end
		end
	end
end
