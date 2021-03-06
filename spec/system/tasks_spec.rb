require 'rails_helper'

describe 'タスク管理機能', type: :system do
  describe '一覧表示機能' do
    let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }    
    let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }    
    
    before do
      admin = FactoryBot.create(:user, admin: true)
    end

    describe 'ログイン機能' do
      before do
        FactoryBot.create(:task, name: "最初のタスク", user: user_a)
        visit login_path
        fill_in 'メールアドレス',  with: login_user.email
        fill_in 'パスワード', with: login_user.password
        click_button 'ログインする'
      end
      
      context 'ユーザAがログインしているとき' do
        let(:login_user) { user_a }
    
        it 'ユーザAが作成したタスクが表示される' do 
          expect(page).to have_content '最初のタスク'
        end
      end
      
      context 'ユーザBがログインしているとき' do
        let(:login_user) { user_b }

        it 'ユーザAが作成したタスクが表示されない' do 
          expect(page).not_to have_content '最初のタスク'
        end
      end
    end
    
    describe '並べ替え機能' do 
      context 'ログイン直後' do
        before do
          FactoryBot.create(:task, name: "1番目", user: user_a, deadline: Date.today )
          FactoryBot.create(:task, name: "2番目", user: user_a, deadline: Date.today + 1.days )
          FactoryBot.create(:task, name: "3番目", user: user_a, deadline: Date.today + 2.days )
  
          visit login_path
          fill_in 'メールアドレス',  with: 'a@example.com'
          fill_in 'パスワード', with: 'password'
          click_button 'ログインする'
        end
        
        it 'タスクが完了期限の昇順に表示される' do 
          within '.table' do
            task_deadlines = all('.deadline').map(&:text)
            expect_deadlines = [Date.today.to_s, (Date.today + 1.days).to_s, (Date.today + 2.days).to_s]
            expect(task_deadlines).to eq expect_deadlines 
          end
        end
      end
      
      context '見出し「優先度」をクリックしたとき' do
        before do
          FactoryBot.create(:task, name: "高", user: user_a, priority: 2)
          FactoryBot.create(:task, name: "中", user: user_a, priority: 1)
          FactoryBot.create(:task, name: "低", user: user_a, priority: 0)
  
          visit login_path
          fill_in 'メールアドレス',  with: 'a@example.com'
          fill_in 'パスワード', with: 'password'
          click_button 'ログインする'
          click_on '優先度'
        end
    
        it 'タスクが優先順位の昇順に表示される' do 
          within '.table' do
            task_names = all('.name').map(&:text)
            expect(task_names).to eq %w(低 中 高) 
          end
        end
  
        it 'もう一度クリックするとタスクが優先順位の降順に表示される' do 
          click_on '優先度'
          within '.table' do
            task_names = all('.name').map(&:text)
            expect(task_names).to eq %w(高 中 低) 
          end
        end
      end
    end

    describe 'タスク検索機能' do
      context 'ユーザAがログインしているとき' do
        before do
          FactoryBot.create(:task, name: "検索対象", user: user_a, priority: 2, status: "未着手")
          FactoryBot.create(:task, name: "非対象", user: user_a, priority: 1, status: "着手中")
          FactoryBot.create(:task, name: "非対象", user: user_a, priority: 0, status: "完了")
          visit login_path
          fill_in 'メールアドレス',  with: 'a@example.com'
          fill_in 'パスワード', with: 'password'
          click_button 'ログインする'

          fill_in '名称', with: '検索対象'
          click_button 'Search'
        end
    
        it 'タスク「検索対象」が表示される' do 
          expect(page).to have_content "検索対象"
        end
      end
      
      context 'ユーザAがログインしているとき' do
        before do
          FactoryBot.create(:task, name: "未着手のタスク", user: user_a, priority: 2, status: "未着手")
          FactoryBot.create(:task, name: "着手中のタスク", user: user_a, priority: 1, status: "着手中")
          FactoryBot.create(:task, name: "完了のタスク", user: user_a, priority: 0, status: "完了")
          visit login_path
          fill_in 'メールアドレス',  with: 'a@example.com'
          fill_in 'パスワード', with: 'password'
          click_button 'ログインする'

          select '未着手', from: '進捗'
          click_button 'Search'
        end
        
        it 'ユーザAが作成したタスクが進捗状況の降順に表示される' do 
          expect(page).to have_content "未着手のタスク"
        end
      end
    end

    describe 'タスク新規登録機能' do
      let(:login_user) { user_a }
      
      before do
        visit login_path
        fill_in 'メールアドレス',  with: login_user.email
        fill_in 'パスワード', with: login_user.password
        click_button 'ログインする'
        click_link 'タスクを新規登録する'

        fill_in 'task_description', with: '詳しい説明 body'
        select '低', from: '優先度'
        select '未着手', from: '進捗'
        fill_in 'task_deadline', with: Date.today

        within '.bootstrap-tagsinput' do
          find('#tagsinputform').set('Tag1')
          find('#tagsinputform').set('Tag2')
        end
      end

      context '新規作成画面で名前を入力したとき' do
        it '正常に登録される' do
          fill_in 'task_name', with: '正常'
          click_button '登録する'

          expect(page).to have_content "正常"
        end
      end
      
      context '新規作成画面で名前を入力しなかったとき' do
        it '登録に失敗する' do
          click_button '登録する'
          expect(page).to have_content "名称を入力してください"
        end
      end
    end

    describe 'タスク編集機能' do
      let(:login_user) { user_a }
      let!(:task_a) { FactoryBot.create(:task, name: "編集前のタスク", user: user_a) }

      before do
        visit login_path
        fill_in 'メールアドレス',  with: login_user.email
        fill_in 'パスワード', with: login_user.password
        click_button 'ログインする'
        visit edit_task_path(task_a)
      end

      it 'ラベルが追加できること' do
        fill_in '名称', with: '編集後のタスク'
        within '.bootstrap-tagsinput' do
          find('#tagsinputform').set('Tag1')
        end
        click_button '更新する'
        expect(page).to have_selector '.alert-success', text: '編集後のタスク'
        expect(page).to have_content 'Tag1'
      end 

      it 'ラベルが削除できること' do
        fill_in '名称', with: '編集後のタスク'
        within '.bootstrap-tagsinput' do
          find('#tagsinputform').set('Tag1')
        end
        click_button '更新する'
        visit edit_task_path(task_a)
        within '.label-info' do
          find('#tag-delete').click
        end
        click_button '更新する'
        expect(page).to have_no_content 'Tag1'
      end 

    end

    describe 'タスク削除機能' do
      let(:login_user) { user_a }
      let!(:task_a) { FactoryBot.create(:task, name: "削除前のタスク", user: user_a) }

      before do
        visit login_path
        fill_in 'メールアドレス',  with: login_user.email
        fill_in 'パスワード', with: login_user.password
        click_button 'ログインする'
      end

      it 'ユーザAが作成したタスクが削除されている' do
        accept_confirm { find('.btn-outline-danger').click }
        within 'table' do
          expect(page).to have_no_content '削除前のタスク'
        end
      end
    end
  end
end
