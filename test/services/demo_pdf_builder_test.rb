require "test_helper"

class DemoPdfBuilderTest < ActiveSupport::TestCase
  test "builds readable demo PDFs" do
    path = Rails.root.join("tmp/demo_pdfs/test-demo.pdf")

    DemoPdfBuilder.call(
      title: "Demo Source",
      body: "Halo customers can freeze a lost card in the app.",
      path: path
    )

    text = PdfTextService.call(path)

    assert_includes text, "Demo Source"
    assert_includes text, "freeze a lost card"
  end
end
