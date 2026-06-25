# frozen_string_literal: true

require "sinatra/base"
require "json"

# YNOT Fitness — Custom Gyms
#
# v1 is a single marketing page with a lead-capture form. It is built on
# Sinatra's modular base so the same app can grow new routes (leads, projects,
# quotes, scheduling) without a rewrite. See BUSINESS.md for the roadmap.
class YnotFitness < Sinatra::Base
  configure do
    set :app_name, "YNOT Fitness — Custom Gyms"
    set :phone, "+1 214-440-8012"
    set :phone_href, "tel:+12144408012"
    set :email, "ynot9097@gmail.com"
    set :public_folder, File.join(__dir__, "public")
    set :views, File.join(__dir__, "views")
    # Where lead submissions are appended until a real datastore (RDS) lands.
    set :leads_file, File.join(__dir__, "data", "leads.jsonl")
  end

  helpers do
    # The four services double as an end-to-end process: design → render →
    # purchase → install. Order matters; the view numbers them as steps.
    def services
      [
        { title: "Design",       blurb: "We plan your space — layout, flooring, walls, mirrors, and the right equipment for your goals and square footage." },
        { title: "Rendering",    blurb: "See it before we build it. We produce a visual rendering of the finished gym so you know exactly what you're getting." },
        { title: "Purchasing",   blurb: "We source the equipment and materials — racks, flooring, mirrors, machines — and handle the buying for you." },
        { title: "Installation", blurb: "Our crew delivers and installs everything: flooring down, mirrors and walls finished, equipment assembled and ready to train." }
      ]
    end

    # Before/After transformations live in public/images/transformations.
    def transformations
      dir = File.join(settings.public_folder, "images", "transformations")
      return [] unless Dir.exist?(dir)

      Dir.children(dir)
         .select { |f| f =~ /\.(png|jpe?g|webp)\z/i }
         .sort
         .map { |f| "/images/transformations/#{f}" }
    end

    # Marketing photos live in public/images. Drop the build-out shots there and
    # they show up in the gallery automatically.
    def gallery_images
      dir = File.join(settings.public_folder, "images")
      return [] unless Dir.exist?(dir)

      Dir.children(dir)
         .select { |f| f =~ /\.(png|jpe?g|webp)\z/i }
         .sort
         .map { |f| "/images/#{f}" }
    end
  end

  get "/" do
    erb :index
  end

  # Lead capture. Starts simple: validate, append to a JSONL file, thank them.
  # Swap the storage for RDS/email when the CRM module lands.
  post "/leads" do
    name  = params[:name].to_s.strip
    phone = params[:phone].to_s.strip
    email = params[:email].to_s.strip
    notes = params[:notes].to_s.strip

    if name.empty? || (phone.empty? && email.empty?)
      status 422
      @error = "Please include your name and a phone or email so we can reach you."
      return erb :index
    end

    record = {
      name: name, phone: phone, email: email, notes: notes,
      received_at: Time.now.utc.iso8601
    }
    FileUtils_mkdir_p(File.dirname(settings.leads_file))
    File.open(settings.leads_file, "a") { |f| f.puts(JSON.generate(record)) }

    @submitted = name
    erb :index
  end

  get "/health" do
    content_type :json
    JSON.generate(status: "ok")
  end

  # Tiny helper to avoid pulling in fileutils at the top for one call.
  def FileUtils_mkdir_p(path)
    require "fileutils"
    FileUtils.mkdir_p(path)
  end

  run! if app_file == $PROGRAM_NAME
end
