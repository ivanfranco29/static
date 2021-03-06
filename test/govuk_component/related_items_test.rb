require 'govuk_component_test_helper'

class RelatedItemsTestCase < ComponentTestCase
  def component_name
    "related_items"
  end

  test "no error if no parameters passed in" do
    assert_nothing_raised do
      assert_empty render_component({})
    end
  end

  test "renders a related items block" do
    render_component(
      sections: [
        {
          title: "Section title",
          url: "/more-link",
          items: [
            {
              title: "Item title",
              url: "/item"
            },
            {
              title: "Other item title",
              url: "/other-item"
            }
          ]
        }
      ],
    )

    assert_select "h2", text: "Section title"
    assert_link_with_text_in("ul li:last-child", "/more-link", /More\s+in\s+Section title/)
    assert_link_with_text_in("ul li:first-child", "/item", "Item title")
    assert_link_with_text_in("ul li:first-child + li", "/other-item", "Other item title")
  end

  test "renders a multiple related items block" do
    render_component(
      sections: [
        {
          title: "Section title",
          url: "/more-link",
          items: [
            {
              title: "Item title",
              url: "/item"
            }
          ]
        },
        {
          title: "Other section title",
          url: "/other-more-link",
          items: [
            {
              title: "Other item title",
              url: "/other-item"
            }
          ]
        }
      ],
    )

    assert_select "h2", text: "Section title"
    assert_link_with_text_in("ul li:last-child", "/more-link", /More\s+in\s+Section title/)
    assert_link_with_text_in("ul li:first-child", "/item", "Item title")

    assert_select "h2", text: "Other section title"
    assert_link_with_text_in("ul li:last-child", "/other-more-link", /More\s+in\s+Other section title/)
    assert_link_with_text_in("ul li:first-child", "/other-item", "Other item title")
  end

  test "renders external links with a rel attribute" do
    render_component(
      sections: [
        {
          title: "Elsewhere on the web",
          url: "/more-link",
          items: [
            {
              title: "Wikivorce",
              url: "http://www.wikivorce.com",
              rel: "external"
            }
          ]
        },
      ],
    )
    assert_select "a[rel=external]", text: "Wikivorce"
  end

  test "includes an id and aria-labelledby when a section id is provided" do
    render_component(
      sections: [
        {
          title: "Elsewhere on the web",
          url: "/more-link",
          id: "related-elsewhere-on-the-web",
          items: [
            {
              title: "Wikivorce",
              url: "http://www.wikivorce.com",
              rel: "external"
            }
          ]
        },
      ],
    )
    assert_select "#related-elsewhere-on-the-web", text: "Elsewhere on the web"
    assert_select "nav[aria-labelledby=related-elsewhere-on-the-web]"
  end

  test "renders all data attributes for tracking" do
    render_component(
      sections: [
        {
          title: "Section title",
          url: "/more-link",
          items: [
            {
              title: "Item title",
              url: "/item"
            },
            {
              title: "Other item title",
              url: "/other-item"
            },
          ]
        },
        {
          title: "Another section",
          url: "/another-more-link",
          items: [
            {
              title: "Foo",
              url: "/foo"
            },
          ],
        },
      ],
    )

    assert_select '.govuk-related-items[data-module="track-click"]', 1

    assert_select "a[data-track-category=\"relatedLinkClicked\"]", 5
    assert_select "a[data-track-dimension-index=\"29\"]", 5
    assert_select "a[data-track-dimension=\"More\"]", 2

    assert_select "a[data-track-action=\"1.1\"]", 1
    assert_select "a[data-track-label=\"/item\"]", 1
    assert_select "a[data-track-dimension=\"Item title\"]", 1

    assert_select "a[data-track-action=\"1.2\"]", 1
    assert_select "a[data-track-label=\"/other-item\"]", 1
    assert_select "a[data-track-dimension=\"Other item title\"]", 1

    assert_select "a[data-track-action=\"1.3\"]", 1
    assert_select "a[data-track-label=\"/more-link\"]", 1

    assert_select "a[data-track-action=\"2.1\"]", 1
    assert_select "a[data-track-label=\"/foo\"]", 1
    assert_select "a[data-track-dimension=\"Foo\"]", 1

    assert_select "a[data-track-action=\"2.2\"]", 1
    assert_select "a[data-track-label=\"/another-more-link\"]", 1
  end
end
