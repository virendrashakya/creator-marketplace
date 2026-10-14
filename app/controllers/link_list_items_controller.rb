# Items inside a link list, and the redirect a fan's tap goes through.
class LinkListItemsController < ApplicationController
  before_action :require_user, except: :visit
  before_action :set_list, except: :visit

  # Three ways in, all from the editor's one bar: a pasted URL, one of the
  # creator's collections, or one of their Shop items.
  def create
    item = @list.items.new(item_params)
    item.position = @list.items.maximum(:position).to_i + 1
    if item.save
      @list.touch
      redirect_to edit_link_list_path(@list), notice: "Added."
    else
      redirect_to edit_link_list_path(@list), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = @list.items.find(params[:id])
    if item.update(item_params.slice(:title, :subtitle, :image_url, :price_label, :url))
      redirect_to edit_link_list_path(@list), notice: "Saved."
    else
      redirect_to edit_link_list_path(@list), alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @list.items.find(params[:id]).destroy
    @list.touch
    redirect_to edit_link_list_path(@list), notice: "Removed from the list."
  end

  # Counts the tap, then sends the fan on. A collection goes to its page on
  # Wishful with the list remembered, so the sale is credited to the list.
  def visit
    item = LinkListItem.includes(:link_list, :product_link, :paid_media_collection).find(params[:id])
    list = item.link_list
    raise ActiveRecord::RecordNotFound unless list.published?

    LinkListItem.where(id: item.id).update_all("clicks_count = clicks_count + 1")

    if item.collection?
      redirect_to public_collection_path(list.user.handle, item.paid_media_collection, list: list.id)
    else
      destination = item.destination_url
      return redirect_to(public_link_list_path(list.user.handle, list.slug), alert: "That link is no longer available.") if ProductLink.http_url_error(destination)

      ProductLink.where(id: item.product_link_id).update_all("clicks_count = clicks_count + 1") if item.product_link_id
      redirect_to destination, allow_other_host: true
    end
  end

  private

  def set_list
    @list = current_user.link_lists.find(params[:link_list_id])
  end

  def item_params
    permitted = params.require(:item).permit(:url, :title, :subtitle, :image_url, :price_label, :product_link_id, :paid_media_collection_id)
    permitted[:url] = normalize_url(permitted[:url]) if permitted[:url].present?
    permitted[:product_link_id] = nil if permitted[:product_link_id].blank?
    permitted[:paid_media_collection_id] = nil if permitted[:paid_media_collection_id].blank?
    permitted
  end

  # People paste "myntra.com/…" without a scheme.
  def normalize_url(value)
    value = value.to_s.strip
    value.match?(%r{\Ahttps?://}i) ? value : "https://#{value}"
  end
end
