require 'test_helper'

class SysConfigsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sys_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sys_config" do
    assert_difference('SysConfig.count') do
      post :create, :sys_config => { }
    end

    assert_redirected_to sys_config_path(assigns(:sys_config))
  end

  test "should show sys_config" do
    get :show, :id => sys_configs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => sys_configs(:one).to_param
    assert_response :success
  end

  test "should update sys_config" do
    put :update, :id => sys_configs(:one).to_param, :sys_config => { }
    assert_redirected_to sys_config_path(assigns(:sys_config))
  end

  test "should destroy sys_config" do
    assert_difference('SysConfig.count', -1) do
      delete :destroy, :id => sys_configs(:one).to_param
    end

    assert_redirected_to sys_configs_path
  end
end
