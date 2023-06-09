import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poom/services/nft_api.dart';
import 'package:poom/widgets/collection/collection_card.dart';
import 'package:poom/widgets/collection/collection_header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  static const Color _textColor = Color(0xFF333333);
  static const _primaryColor = Color(0xFFFF8E01);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  bool _isGrid = false;
  final bool _isOwner = false;
  bool _isDialogOpen = false;
  final imagePicker = ImagePicker();
  late Future<Map<String, dynamic>> result;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool hasMore = false;
  int pageNum = 0;
  int nftCount = 0;
  List<dynamic> list = [];

  @override
  void initState() {
    super.initState();
    result = NftApiService().getUserNFTList(context, 0);
  }

  // 다이얼로그 안내
  Future<void> showCustomDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          elevation: 1,
          title: const Text(
            "NFT 컬렉션 공유",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "인스타그램을 먼저 설치해주세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          buttonPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          actions: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: CollectionScreen._primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: 42,
              child: TextButton(
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  _isDialogOpen = false;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!hasMore) return;
    if (nftCount != 0 && nftCount == list.length) return;
    pageNum += 1;
    var data = await NftApiService().getUserNFTList(context, pageNum);
    List<dynamic> moreNftList = data["nftImgUrls"];
    hasMore = data["hasMore"];
    list.addAll(moreNftList);
    _refreshController.loadComplete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: CollectionScreen._textColor,
          shadowColor: const Color(0xFFE4E4E4),
          centerTitle: true,
          elevation: 1,
          title: const Text(
            "NFT 컬렉션",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        child: FutureBuilder(
          future: result,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              hasMore = snapshot.data!["hasMore"];
              var nickname = snapshot.data!["nickname"];
              nftCount = snapshot.data!["nftCount"];
              var nftImgUrls = snapshot.data!["nftImgUrls"];
              list = nftImgUrls;

              if (nftCount == 0) {
                return const Center(
                  child: Text(
                    "소유한 NFT가 없어요!",
                    style: TextStyle(
                      color: Color(0xFF333333),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CollectionHeader(
                          nickName: nickname, totalCount: nftCount),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGrid = !_isGrid;
                          });
                        },
                        child: Icon(_isGrid
                            ? Icons.view_agenda
                            : Icons.grid_view_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: SmartRefresher(
                      onLoading: _onLoading,
                      onRefresh: _onRefresh,
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isGrid ? 2 : 1,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: _isGrid ? 1 : 1 / 1.32,
                        ),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CollectionCard(
                              imageUrl: list[index],
                              isGrid: _isGrid,
                              isOwner: _isOwner,
                              isDialogOpen: _isDialogOpen,
                              showCustomDialog: showCustomDialog,
                              setShowDialog: () {
                                _isDialogOpen = true;
                              });
                        },
                      ),
                    ),
                  ),
                ],
              );
            }

            return Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey.shade400),
                        width: 160,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _isGrid ? 2 : 1,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 5,
                        childAspectRatio: _isGrid ? 1 : 1 / 1.32,
                      ),
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.hardEdge,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
