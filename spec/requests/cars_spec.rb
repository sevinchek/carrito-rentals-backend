require 'rails_helper'
require 'json'

RSpec.describe 'Cars API', js: true, type: :request do
  before(:all) do
    @user1 = User.create(username: 'mike1000')
    @user2 = User.create(username: 'johndoe')
    @car1 = Car.create(brand: 'Ford', model: 'Fiesta 2021', seats_number: 5, transmision: 'automatic',
                       mileage: 'unlimited', image: 'https://www.actualidadmotor.com/wp-content/uploads/2021/09/ford-fiesta-1.jpg',

                       price_for_day: 120, bags_number: 2, user_id: @user1.id)
    @car2 = Car.create(brand: 'BMW', model: '320i 2020', seats_number: 5, transmision: 'automatic',
                       mileage: 'unlimited', image: 'https://bmwco.vteximg.com.br/arquivos/ids/158217-1440-810/BMW-image-5F31-B39-KCFY-main-556.jpg',
                       price_for_day: 199.9, bags_number: 2, user_id: @user1.id)
    @car3 = Car.create(brand: 'Mazda', model: 'CX30 2019', seats_number: 5, transmision: 'automatic',
                       mileage: 'unlimited', image: 'https://mazdacol.vteximg.com.br/arquivos/ids/162482-1200-900/CX-5_KFL6_KCJ1LAA_46G_KD4_EXT_MAIN_TOURING_2.0L.jpg',
                       price_for_day: 249.9, bags_number: 4, user_id: @user1.id)
    Rental.create(start_date: '10-12-2021', end_date: '22-12-2021', city: 'Medellin', user_id: @user1.id,
                  car_id: @car1.id)
    Rental.create(start_date: '15-12-2021', end_date: '10-01-2022', city: 'Lima', user_id: @user1.id, car_id: @car2.id)
    Rental.create(start_date: '18-12-2021', end_date: '31-12-2021', city: 'Montego Bay', user_id: @user1.id,
                  car_id: @car3.id)
  end

  describe 'GET /v1/cars' do
    before { get '/v1/cars', params: {}, headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) } }

    it 'returns cars' do
      expect(JSON.parse(response.body)).not_to be_empty
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /v1/cars/:id' do
    context 'when the record exists' do
      before do
        get "/v1/cars/#{@car1.id}", params: {},
                                    headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) }
      end

      it 'returns the todo' do
        expect(JSON.parse(response.body)).not_to be_empty
        expect(JSON.parse(response.body)['id']).to eq(@car1.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      before do
        get '/v1/cars/123', params: {}, headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(JSON.parse(response.body)['message']).to match(/Couldn't find Car with 'id'=123/)
      end
    end
  end

  describe 'POST /v1/cars' do
    new_car = { brand: 'Volkswagen', model: 'Combi 2000', seats_number: 10, transmision: 'mecanic',
                mileage: 'unlimited', image: 'https://mazdacol.vteximg.com.br/volkswagen-combi.jpg',
                price_for_day: 109.9, bags_number: 4 }

    context 'when the request is valid' do
      before do
        post '/v1/cars', params: new_car, headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) }
      end

      it 'creates a car' do
        expect(JSON.parse(response.body)['brand']).to eq('Volkswagen')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do
        post '/v1/cars', params: { brand: 'Foobar' },
                         headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(JSON.parse(response.body)['message'])
          .to match(/Car couldn't be saved/)
      end
    end
  end

  describe 'DELETE /v1/cars/:id' do
    before do
      delete "/v1/cars/#{@car1.id}", params: {},
                                     headers: { Authorization: JsonWebToken.encode({ user_id: User.first.id }) }
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
